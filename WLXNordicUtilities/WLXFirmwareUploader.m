//
//  WLXFirmwareUploader.m
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/7/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXFirmwareUploader.h"
#import "WLXNordicUtilitiesErrors.h"
#import "WLXNordicUtilitiesLogger.h"

typedef enum {
    Softdevice = 0x01,
    Bootloader = 0x02,
    SoftdeviceAndBootloader = 0x03,
    Application = 0x04
} WLXFirmwareType;

typedef enum {
    StartDFURequest = 0x01,
    InitializeDFUParametersRequest = 0x02,
    ReceiveFirmwareImageRequest = 0x03,
    ValidateFirmwareRequest = 0x04,
    ActivateAndResetRequest = 0x05,
    ResetSystem = 0x06,
    PacketReceiptNotificationRequest = 0x08,
    ResponseCode = 0x10,
    PacketReceiptNotificationResponse = 0x11
} WLXDFUOperation;

typedef enum {
    OperationSuccessfull = 0x01,
    OperationInvalid = 0x02,
    OperationNotSupported = 0x03,
    DataSizeExceedsLimit = 0x04,
    CRCError = 0x05,
    OperationFailed = 0x06
} WLXDFUOperationStatus;

#pragma pack(1)

typedef struct {
    WLXDFUOperation responseCode;
    WLXDFUOperation requestCode;
    WLXDFUOperationStatus responseStatus;
} WLXDFUControlPointNotification;

#pragma options align=reset

typedef enum {
    StartInitPacket,
    EndInitPacket
} WLXInitPacket;

static const int PacketsNotificationInterval = 10;

// DFUService characteristics UUIDs
static NSString * const DFUControlPointCharacteristicUUIDString = @"00001531-1212-EFDE-1523-785FEABCD123";
static NSString * const DFUPacketCharacteristicUUIDString = @"00001532-1212-EFDE-1523-785FEABCD123";
static NSString * const DFUVersionCharacteritsicUUIDString = @"00001534-1212-EFDE-1523-785FEABCD123";


@interface WLXFirmwareUploadChunk ()

- (instancetype)initWithTransferedBytes:(NSUInteger)transferedBytes
                   totalBytesToTransfer:(NSUInteger)totalBytesToTransfer;

@end

@implementation WLXFirmwareUploadChunk

- (instancetype)initWithTransferedBytes:(NSUInteger)transferedBytes
                   totalBytesToTransfer:(NSUInteger)totalBytesToTransfer {
    if (self = [super init]) {
        _transferedBytes = transferedBytes;
        _totalBytesToTransfer = totalBytesToTransfer;
    }
    return self;
}

@end

@interface WLXFirmwareUploader ()

@property (nonatomic) CBUUID * DFUControlPointCharacteristicUUID;
@property (nonatomic) CBUUID * DFUPacketCharacteristicUUID;
@property (nonatomic) CBUUID * DFUVersionCharacteritsicUUID;

@property (nonatomic) WLXServiceManager * DFUServiceManager;
@property (nonatomic) WLXFirmwareArchive * firmwareArchive;
@property (nonatomic) WLXReactiveConnectionManagerDelegate * connectionManagerDelegate;

@property (nonatomic) NSUInteger transferedBytes;
@property (nonatomic) NSUInteger totalBytesToTransfer;
@property (nonatomic) NSUInteger packetIndex;

@property (nonatomic) BOOL uploading;

@end

@implementation WLXFirmwareUploader

WLX_NU_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithDFUServiceManager:(WLXServiceManager *)DFUServiceManager
                                 delegate:(WLXReactiveConnectionManagerDelegate *)delegate
                                 firmware:(WLXFirmwareArchive *)firmwareArchive; {
    WLXAssertNotNil(DFUServiceManager);
    WLXAssertNotNil(delegate);
    if (self = [super init]) {
        _DFUServiceManager = DFUServiceManager;
        _DFUControlPointCharacteristicUUID = [CBUUID UUIDWithString:DFUControlPointCharacteristicUUIDString];
        _DFUPacketCharacteristicUUID = [CBUUID UUIDWithString:DFUPacketCharacteristicUUIDString];
        _DFUVersionCharacteritsicUUID = [CBUUID UUIDWithString:DFUVersionCharacteritsicUUIDString];
        _firmwareArchive = firmwareArchive;
        _totalBytesToTransfer = firmwareArchive.metadata.length + firmwareArchive.binary.length;
        _packetIndex = 0;
        _connectionManagerDelegate = delegate;
        _uploading = NO;
    }
    return self;
}

- (RACSignal *)uploadFirmware {
    if (self.uploading) {
        return [RACSignal error:AlreadyUploadingFirmwareError()];
    }
    
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.uploading = YES;
        WLXNULogDebug(@"Starting process of uploading firmware");
        [[[[[[self enableControlPointNotifications]
           then:^{ return [self startDFURequest]; }]
           then:^{ return [self writeFirmwareFileSize:(uint32_t)self.firmwareArchive.binary.length]; }]
           // TODO: We should probably do something with this value.
           // I am not sure. The Nordic iOS Tools does nothing with this value. Maybe we should
           // check that this value matches the DFU version attribute in manifest.json
           then:^{ return [self readDFUVersion]; }]
           then:^{ return [self subscribeToControlPointNotifications]; }]
         subscribeNext:^(NSData * data) {
             WLXDFUControlPointNotification notification;
             notification.responseCode = ((uint8_t *)data.bytes)[0];
             notification.requestCode = ((uint8_t *)data.bytes)[1];
             notification.responseStatus = ((uint8_t *)data.bytes)[2];
             [self processControlPointNotification:notification withSubscriber:subscriber];
         } error:^(NSError *error) {
             [self resetSystem];
             [subscriber sendError:error];
         }];
        
        return nil;
    }] merge:[self.connectionManagerDelegate.connectionLost flattenMap:^(NSError * error) {
        return [RACSignal error:error];
    }]] doCompleted:^{ self.uploading = NO; }] doError:^(NSError *error) { self.uploading = NO; }];
}

#pragma mark - Private methods

- (RACSignal *)enableControlPointNotifications {
    return [self.DFUServiceManager rac_enableNotificationsForCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (RACSignal *)startDFURequest {
    WLXNULogDebug(@"starting DFU request");
    uint8_t value[] = {StartDFURequest, Application};
    NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
    return [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (RACSignal *)writeFirmwareFileSize:(uint32_t)firmwareFileSize {
    WLXNULogDebug(@"writting firmware file size");
    uint32_t fileSizeCollection[3] = {0, 0, firmwareFileSize};
    NSData * data = [NSData dataWithBytes:&fileSizeCollection length:sizeof(fileSizeCollection)];
    // We are writting without response because that is how the Nordic iOS Tools does it.
    [self.DFUServiceManager writeValue:data toCharacteristic:self.DFUPacketCharacteristicUUID];
    return [RACSignal empty];
}

- (RACSignal *)readDFUVersion {
    WLXNULogDebug(@"Reading DFU version");
    return [[self.DFUServiceManager rac_readValueFromCharacteristic:self.DFUVersionCharacteritsicUUID] doNext:^(NSData * data) {
        uint8_t * version = (uint8_t *)data.bytes;
        WLXNULogDebug(@"DFU Version is %d %d", version[0], version[1]);
    }];
}

- (RACSignal *)subscribeToControlPointNotifications {
    WLXNULogDebug(@"Subscribing to control point notifications");
    return [self.DFUServiceManager rac_notificationsForCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (void)processControlPointNotification:(WLXDFUControlPointNotification)notification
                                withSubscriber:(id<RACSubscriber>)subscriber {
    int code = notification.responseCode;
    WLXNULogDebug(@"processing control point notification with response code %d", code);
    switch (notification.responseCode) {
        case PacketReceiptNotificationResponse:
            [self processPacketReceiptNotificationResponseWithSubscriber:subscriber];
            break;
        case ResponseCode:
            [self processRequest:notification withSubscriber:subscriber];
            break;
        default:
            [subscriber sendError:UnsupportedResponseOperationError()];
            break;
    }
}

- (WLXFirmwareUploadChunk *)transferedChunk {
    return [[WLXFirmwareUploadChunk alloc] initWithTransferedBytes:self.transferedBytes
                                              totalBytesToTransfer:self.totalBytesToTransfer];
}

- (void)processPacketReceiptNotificationResponseWithSubscriber:(id<RACSubscriber>)subscriber {
    [subscriber sendNext:[self transferedChunk]];
    [self writeFirmwarePacket];
}

- (void)processRequest:(WLXDFUControlPointNotification)request withSubscriber:(id<RACSubscriber>)subscriber {
    switch (request.requestCode) {
        case StartDFURequest:
            [self processStartDFURequest:request.responseStatus withSubscriber:subscriber];
            break;
        case ReceiveFirmwareImageRequest:
            [self processReceiveFirmwareImageRequest:request.responseStatus withSubscriber:subscriber];
            break;
        case ValidateFirmwareRequest:
            [self processValidateFirmwareRequest:request.responseStatus withSubscriber:subscriber];
            break;
        case InitializeDFUParametersRequest:
            [self processInitializeDFUParametersRequest:request.responseStatus withSubscriber:subscriber];
            break;
        default:
            break;
    }
}

- (void)writeFirmwarePacket {
    for (NSUInteger i = 0; i < PacketsNotificationInterval && self.packetIndex < self.firmwareArchive.binaryPacketsCount; ++i) {
        NSUInteger packetBytesAmount;
        if (self.packetIndex == self.firmwareArchive.binaryPacketsCount - 1) {
            packetBytesAmount = self.firmwareArchive.binary.length % WLXMaxAmountOfBytesPerPacket;
        } else {
            packetBytesAmount = WLXMaxAmountOfBytesPerPacket;
        }
        WLXNULogVerbose(@"Sending firmware packet number %ld. Transfered bytes %ld / %ld",
                        self.packetIndex, self.transferedBytes, self.firmwareArchive.binary.length);
        NSRange dataRange = NSMakeRange(self.packetIndex * WLXMaxAmountOfBytesPerPacket, packetBytesAmount);
        NSData * data = [self.firmwareArchive.binary subdataWithRange:dataRange];
        [self.DFUServiceManager writeValue:data toCharacteristic:self.DFUPacketCharacteristicUUID];
        self.packetIndex++;
        self.transferedBytes += packetBytesAmount;
    }
}

- (void)processStartDFURequest:(WLXDFUOperationStatus)status withSubscriber:(id<RACSubscriber>)subscriber {
    if (status == OperationSuccessfull) {
        [[self sendMetadata] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            self.transferedBytes = self.firmwareArchive.metadata.length;
            [subscriber sendNext:[self transferedChunk]];
        }];
    } else {
        [subscriber sendError:FailToStartDFUError()];
    }
}

- (void)sendMetadataPacket:(NSUInteger)packetNumber isLastPacket:(BOOL)isLastPacket {
    NSUInteger packetBytesAmount;
    if (isLastPacket) {
        packetBytesAmount = self.firmwareArchive.metadata.length % WLXMaxAmountOfBytesPerPacket;
    } else {
        packetBytesAmount = WLXMaxAmountOfBytesPerPacket;
    }
    WLXNULogVerbose(@"Sending metadata packet number %ld. Transfered bytes %ld / %ld",
                    packetNumber, packetBytesAmount, self.firmwareArchive.metadata.length);
    NSRange dataRange = NSMakeRange(packetNumber * WLXMaxAmountOfBytesPerPacket,  packetBytesAmount);
    NSData * packetData = [self.firmwareArchive.metadata subdataWithRange:dataRange];
    [self.DFUServiceManager writeValue:packetData toCharacteristic:self.DFUPacketCharacteristicUUID];
}

- (RACSignal *)sendMetadataControlPacket:(WLXInitPacket)packetValue {
    uint8_t packet[] = {InitializeDFUParametersRequest, packetValue};
    NSData * data = [NSData dataWithBytes:&packet length:sizeof(packet)];
    return [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (RACSignal *)sendMetadata {
    WLXNULogDebug(@"Sending metadata of size %ld bytes", self.firmwareArchive.metadata.length);
    return [[[self sendMetadataControlPacket:StartInitPacket] then:^{
        NSUInteger i, packets;
        for (i = 0, packets =  self.firmwareArchive.metadataPacketsCount - 1; i < packets; ++i) {
            [self sendMetadataPacket:i isLastPacket:NO];
        }
        [self sendMetadataPacket:i isLastPacket:YES];
        self.transferedBytes = self.firmwareArchive.metadata.length;
        
        return [self sendMetadataControlPacket:EndInitPacket];
    }] catchTo:[RACSignal error:FailToSendMetadataError()]];
}

- (RACSignal *)enablePacketNotifications {
    WLXNULogDebug(@"Enable packet notifications");
    uint8_t value[] = {PacketReceiptNotificationRequest, PacketsNotificationInterval, 0};
    NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
    return [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (RACSignal *)sendReceiveFirmwareImageRequest {
    WLXNULogDebug(@"Send receive firmware image request");
    uint8_t value = ReceiveFirmwareImageRequest;
    NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
    return [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
}

- (void)processInitializeDFUParametersRequest:(WLXDFUOperationStatus)status
                               withSubscriber:(id<RACSubscriber>)subscriber {
    if (status == OperationSuccessfull) {
        WLXNULogDebug(@"Metadata successfully uploaded.");
        WLXNULogDebug(@"Setting up DFU to send firmware binary file.");
        [[[self enablePacketNotifications]
          then:^{ return [self sendReceiveFirmwareImageRequest]; }]
          subscribeError:^(NSError *error) {
              [subscriber sendError:error];
          } completed:^{
              WLXNULogDebug(@"Sending first firmware binary packet");
              [self writeFirmwarePacket];
          }];
    } else {
        [subscriber sendError:FailToSendMetadataError()];
    }
}

- (void)processReceiveFirmwareImageRequest:(WLXDFUOperationStatus)status withSubscriber:(id<RACSubscriber>)subscriber {
    if (status == OperationSuccessfull) {
        WLXNULogDebug(@"Firmware has been received. Validating it.");
        uint8_t packet = ValidateFirmwareRequest;
        NSData * data = [NSData dataWithBytes:&packet length:sizeof(packet)];
        [[self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID]
         subscribeError:^(NSError *error) { [subscriber sendError:FailToValidateFirmwareError()]; }];
    } else {
        [subscriber sendError:FailToUploadFirmwareError()];
    }
}

- (void)processValidateFirmwareRequest:(WLXDFUOperationStatus)status withSubscriber:(id<RACSubscriber>)subscriber {
    if (status == OperationSuccessfull) {
        WLXNULogDebug(@"Firmware has been validated. Activating and resetting device.");
        uint8_t packet = ActivateAndResetRequest;
        NSData * data = [NSData dataWithBytes:&packet length:sizeof(packet)];
        [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
        [subscriber sendCompleted];
    } else {
        [subscriber sendError:FailToValidateFirmwareError()];
    }
}

- (RACSignal *)resetSystem {
    uint8_t packet = ResetSystem;
    NSData * data = [NSData dataWithBytes:&packet length:sizeof(packet)];
    return [self.DFUServiceManager rac_writeValue:data toCharacteristic:self.DFUControlPointCharacteristicUUID];
}

@end

//
//  NRF51XXDeviceManager.m
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXNRF51XXDeviceManager.h"

NSString * const DFUServiceUUIDString = @"00001530-1212-EFDE-1523-785FEABCD123";
NSString * const ANCSServiceUUIDString = @"7905F431-B5CE-4E99-A40F-4B1E122D00D0";

const NSUInteger DefaultDiscoveryTimeout = 30000; // 30s
const NSUInteger DefaultConnectionTimeout = 2000; // 2s

NSString * const WLXNRF51XXDeviceManagerErrorDomain = @"ar.com.wolox.WLXNRF51XXDeviceManagerErrorDomain";

@interface WLXNRF51XXDeviceManager ()

@property WLXBluetoothDeviceManager * bluetoothDeviceManager;
@property WLXReactiveDeviceDiscovererDelegate * discovererDelegate;
@property WLXReactiveConnectionManagerDelegate * connectionManagerDelegate;
@property NSArray * discoveryServices;
@property WLXFirmwareUploader * connectedUploader;
@property CBUUID * DFUServiceUUID;
@property CBUUID * ANCSServiceUUID;

@end

@implementation WLXNRF51XXDeviceManager

+ (instancetype)defaultDeviceManager {
    WLXBluetoothDeviceManager * bluetoothDeviceManager = [WLXBluetoothDeviceManager deviceManager];
    return [[self alloc] initWithBluetoothDeviceManager:bluetoothDeviceManager];
}

- (instancetype)initWithBluetoothDeviceManager:(WLXBluetoothDeviceManager *)bluetoothDeviceManager {
    WLXAssertNotNil(bluetoothDeviceManager);
    if (self = [super init]) {
        _bluetoothDeviceManager = bluetoothDeviceManager;
        _discovererDelegate = [[WLXReactiveDeviceDiscovererDelegate alloc] init];
        _connectionManagerDelegate = [[WLXReactiveConnectionManagerDelegate alloc] init];
        _bluetoothDeviceManager.discoverer.delegate = _discovererDelegate;
        _discoveryTimeout = DefaultDiscoveryTimeout;
        _connectionTimeout = DefaultConnectionTimeout;
        _DFUServiceUUID = [CBUUID UUIDWithString:DFUServiceUUIDString];
        _ANCSServiceUUID = [CBUUID UUIDWithString:ANCSServiceUUIDString];
        _discoveryServices = @[_DFUServiceUUID, _ANCSServiceUUID];
    }
    return self;
}

- (RACSignal *)connectWithDFUDevice {
    if (self.connectedUploader != nil) {
        return [RACSignal error:[NSError errorWithDomain:WLXNRF51XXDeviceManagerErrorDomain
                                                    code:DeviceAlreadyConnected
                                                userInfo:nil]];
    }
    
    return [[[self discoverDFUDevices] flattenMap:^(WLXDeviceDiscoveryData * discoveryData) {
        return [[self connectWithDevice:discoveryData] map:^(id<WLXConnectionManager> connectionManager) {
            return [[WLXFirmwareUploader alloc] initWithConnectionManager:connectionManager
                                                                 delegate:self.connectionManagerDelegate];
        }];
    }] doNext:^(WLXFirmwareUploader * uploader) {
        self.connectedUploader = uploader;
    }];
}

#pragma mark - Private methods

- (id<WLXDeviceDiscoverer>)discoverer {
    return self.bluetoothDeviceManager.discoverer;
}

// @return A signal that when subscribed it will discover and send the first DFU device that
// it is advertaising DFU services.
- (RACSignal *)discoverDFUDevices {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self.discovererDelegate.discoveredDevice take:1]
         takeUntil:self.discovererDelegate.stopDiscoveringDevices]
         subscribe:subscriber];
        
        BOOL discovering = [self.discoverer discoverDevicesNamed:nil
                                                    withServices:self.discoveryServices
                                                      andTimeout:self.discoveryTimeout];
        
        if (!discovering) {
            NSError * error = [NSError errorWithDomain:WLXNRF51XXDeviceManagerErrorDomain
                                                  code:CannotDiscoverDFUDevices
                                              userInfo:nil];
            [subscriber sendError:error];
        }
        
        return [RACDisposable disposableWithBlock:^{
            if (self.discoverer.discovering) {
                [self.discoverer stopDiscoveringDevices];
            }
        }];
    }];
}

- (id<WLXConnectionManager>)connectionManagerForPeripheral:(CBPeripheral *)peripheral {
    id<WLXReconnectionStrategy> strategy = [[WLXNullReconnectionStrategy alloc] init];
    id<WLXConnectionManager> connectionManager = [self.bluetoothDeviceManager connectionManagerForPeripheral:peripheral
                                                                                   usingReconnectionStrategy:strategy];
    connectionManager.delegate = self.connectionManagerDelegate;
    connectionManager.allowReconnection = NO;
    return connectionManager;
}

- (RACSignal *)connectionEstablished {
    RACSignal * success = [self.connectionManagerDelegate.connectionEstablished take:1];
    RACSignal * failure = [self.connectionManagerDelegate.failToConnect take:1];
    return [[[RACSignal merge:@[success, failure]] take:1] flattenMap:^(id value) {
        if ([value isKindOfClass:[NSError class]]) {
            return [RACSignal error:value];
        }
        return [RACSignal return:value];
    }];
}

// @return A signal that when subscribed will connect with the peripheral
// and will try yo discover its services and if it success it will send
// the connection manager for the connected device.
- (RACSignal *)connectWithDevice:(WLXDeviceDiscoveryData *)discoveryData {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        id<WLXConnectionManager> connectionManager = [self connectionManagerForPeripheral:discoveryData.peripheral];
        [[self.connectionEstablished flattenMap:^(id value) {
            return [[connectionManager.servicesManager rac_discoverServices] mapReplace:connectionManager];
        }] subscribe:subscriber];
        
        [connectionManager connectWithTimeout:self.connectionTimeout];
        
        // TODO cancel connection process. This feature is not supported by WLXBluetoothDevice yet.
        return nil;
    }];
}

@end

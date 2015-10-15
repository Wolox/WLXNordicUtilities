//
//  WLXFirmwareUploader.h
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/7/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WLXBluetoothDevice/WLXBluetoothDevice.h>
#import <WLXBluetoothDeviceReactiveExtensions/WLXBluetoothDeviceReactiveExtensions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "WLXFirmwareArchive.h"

@interface WLXFirmwareUploadChunk : NSObject

@property (nonatomic, readonly) NSUInteger transferedBytes;
@property (nonatomic, readonly) NSUInteger totalBytesToTransfer;

@end

@interface WLXFirmwareUploader : NSObject

- (instancetype)initWithDFUServiceManager:(WLXServiceManager *)DFUServiceManager
                                 delegate:(WLXReactiveConnectionManagerDelegate *)delegate
                                 firmware:(WLXFirmwareArchive *)firmwareArchive;

// @return A signal that when subscribed starts uploading the firmware
// and send WLXFirmwareUploadChunk object for every firmware chunk.
- (RACSignal *)uploadFirmware;

@end

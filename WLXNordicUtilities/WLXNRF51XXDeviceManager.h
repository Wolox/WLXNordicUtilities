//
//  NRF51XXDeviceManager.h
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WLXBluetoothDevice/WLXBluetoothDevice.h>
#import <WLXBluetoothDeviceReactiveExtensions/WLXBluetoothDeviceReactiveExtensions.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "WLXFirmwareUploader.h"

extern NSString * const DFUServiceUUIDString;
extern NSString * const ANCSServiceUUIDString;

@interface WLXNRF51XXDeviceManager : NSObject

@property NSUInteger discoveryTimeout;
@property NSUInteger connectionTimeout;

+ (instancetype)defaultDeviceManager;

// @return A signal that when subscribed starts discovering
// devices in DFU and connect with the first one it discoveres.
// Upon establishing a connection it will upload the given
// application firmware. It will send WLXFirmwareUploadChunk
// objects for every firmware chunk uploaded.
- (RACSignal *)connectWithDFUDevice:(NSString *)deviceName andUploadFirmware:(WLXFirmwareArchive *)firmwareArchive;

@end

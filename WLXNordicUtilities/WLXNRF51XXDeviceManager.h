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

extern NSString * const WLXNRF51XXDeviceManagerErrorDomain;
typedef enum : NSUInteger {
    DeviceAlreadyConnected,
    CannotDiscoverDFUDevices
} WLXNRF51XXDeviceManagerError;

@interface WLXNRF51XXDeviceManager : NSObject

@property NSUInteger discoveryTimeout;
@property NSUInteger connectionTimeout;

- (RACSignal *)connectWithDFUDevice;

@end

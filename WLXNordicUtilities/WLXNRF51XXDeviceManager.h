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

#import "WLXFirmwareArchive.h"

@interface WLXNRF51XXDeviceManager : NSObject

- (RACSignal *)connectWithDFUDevice;

- (RACSignal *)uploadFirmware:(WLXFirmwareArchive *)firmwareArchive;

@end

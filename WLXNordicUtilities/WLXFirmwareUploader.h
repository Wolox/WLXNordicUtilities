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

@interface WLXFirmwareUploader : NSObject

- (instancetype)initWithConnectionManager:(id<WLXConnectionManager>)connectionManager
                                 delegate:(WLXReactiveConnectionManagerDelegate *)delegate;

- (RACSignal *)uploadFirmware:(WLXFirmwareArchive *)firmwareArchive;

@end

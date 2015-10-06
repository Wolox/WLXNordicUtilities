//
//  FirmwareArchive.m
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXFirmwareArchive.h"
#import <WLXBluetoothDevice/WLXBluetoothDevice.h>

@implementation WLXFirmwareArchive

- (instancetype)initWithManifest:(NSDictionary *)manifest binary:(NSData *)binary metadata:(NSData *)metadata {
    WLXAssertNotNil(manifest);
    WLXAssertNotNil(binary);
    WLXAssertNotNil(metadata);
    if (self) {
        _manifest = manifest;
        _binary = binary;
        _metadata = metadata;
    }
    return self;
}

@end

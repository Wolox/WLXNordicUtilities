//
//  FirmwareArchive.m
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXFirmwareArchive.h"
#import <WLXBluetoothDevice/WLXBluetoothDevice.h>

const NSUInteger WLXMaxAmountOfBytesPerPacket = 20;

static NSUInteger calculatePacketsCount(NSData * data) {
    return (data.length / WLXMaxAmountOfBytesPerPacket) + (data.length % WLXMaxAmountOfBytesPerPacket != 0);
}

@implementation WLXFirmwareArchive

- (instancetype)initWithManifest:(NSDictionary *)manifest binary:(NSData *)binary metadata:(NSData *)metadata {
    WLXAssertNotNil(manifest);
    WLXAssertNotNil(binary);
    WLXAssertNotNil(metadata);
    if (self) {
        _manifest = manifest;
        _binary = binary;
        _metadata = metadata;
        _binaryPacketsCount = calculatePacketsCount(binary);
        _metadataPacketsCount = calculatePacketsCount(metadata);
    }
    return self;
}

@end

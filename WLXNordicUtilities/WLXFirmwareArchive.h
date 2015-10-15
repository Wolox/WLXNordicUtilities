//
//  FirmwareArchive.h
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger WLXMaxAmountOfBytesPerPacket;

@interface WLXFirmwareArchive : NSObject

@property (nonatomic, readonly) NSDictionary * manifest;
@property (nonatomic, readonly) NSData * binary;
@property (nonatomic, readonly) NSData * metadata;

@property (nonatomic, readonly) NSUInteger binaryPacketsCount;
@property (nonatomic, readonly) NSUInteger metadataPacketsCount;

- (instancetype)initWithManifest:(NSDictionary *)manifest binary:(NSData *)binary metadata:(NSData *)metadata;

@end

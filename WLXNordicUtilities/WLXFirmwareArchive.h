//
//  FirmwareArchive.h
//  WLXBluetoothDevice+NRF51XX
//
//  Created by Guido Marucci Blas on 10/6/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLXFirmwareArchive : NSObject

@property (nonatomic, readonly) NSDictionary * manifest;
@property (nonatomic, readonly) NSData * binary;
@property (nonatomic, readonly) NSData * metadata;

- (instancetype)initWithManifest:(NSDictionary *)manifest binary:(NSData *)binary metadata:(NSData *)metadata;

@end

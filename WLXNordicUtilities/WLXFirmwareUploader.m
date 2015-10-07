//
//  WLXFirmwareUploader.m
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/7/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXFirmwareUploader.h"

@implementation WLXFirmwareUploader

- (instancetype)initWithConnectionManager:(id<WLXConnectionManager>)connectionManager
                                 delegate:(WLXReactiveConnectionManagerDelegate *)delegate {
    WLXAssertNotNil(connectionManager);
    WLXAssertNotNil(delegate);
    if (self = [super init]) {
        
    }
    return self;
}

- (RACSignal *)uploadFirmware:(WLXFirmwareArchive *)firmwareArchive {
    return nil;
}

@end

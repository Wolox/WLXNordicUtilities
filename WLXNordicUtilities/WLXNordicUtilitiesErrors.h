//
//  WLXNordicUtilitiesErrors.h
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/15/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WLXNordicUtilitiesErrorDomain;
typedef enum : NSUInteger {
    CannotDiscoverDFUDevices,
    UnsupportedResponseOperation,
    AlreadyUploadingFirmware,
    FailToStartDFU,
    FailToSendMetadata,
    FailToUploadFirmware,
    FailToValidateFirmware,
    FailToActivateFirmware
} WLXNordicUtilitiesErrors;

NSError * CannotDiscoverDFUDevicesError();
NSError * UnsupportedResponseOperationError();
NSError * AlreadyUploadingFirmwareError();
NSError * FailToStartDFUError();
NSError * FailToSendMetadataError();
NSError * FailToUploadFirmwareError();
NSError * FailToValidateFirmwareError();
NSError * FailToActivateFirmwareError();
//
//  WLXNordicUtilitiesErrors.m
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/15/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXNordicUtilitiesErrors.h"

NSString * const WLXNordicUtilitiesErrorDomain = @"ar.com.wolox.WLXNordicUtilitiesError";

NSError * CannotDiscoverDFUDevicesError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:CannotDiscoverDFUDevices userInfo:nil];
}

NSError * UnsupportedResponseOperationError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:UnsupportedResponseOperation userInfo:nil];
}

NSError * AlreadyUploadingFirmwareError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:AlreadyUploadingFirmware userInfo:nil];
}

NSError * FailToStartDFUError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToStartDFU userInfo:nil];
}

NSError * FailToSendMetadataError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToSendMetadata userInfo:nil];
}

NSError * FailToUploadFirmwareError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToUploadFirmware userInfo:nil];
}

NSError * FailToValidateFirmwareError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToValidateFirmware userInfo:nil];
}

NSError * FailToActivateFirmwareError() {
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToActivateFirmware userInfo:nil];
}
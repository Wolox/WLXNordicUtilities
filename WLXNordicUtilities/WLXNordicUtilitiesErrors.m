//
//  WLXNordicUtilitiesErrors.m
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/15/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXNordicUtilitiesErrors.h"

static NSString * getErrorMessage(WLXNordicUtilitiesErrors error) {
    switch (error) {
        case CannotDiscoverDFUDevices:
            return @"Cannot discover DFU devices";
        case UnsupportedResponseOperation:
            return @"Unsupported response operation";
        case AlreadyUploadingFirmware:
            return @"Already uploading firmware";
        case FailToStartDFU:
            return @"Fail to start DFU";
        case FailToSendMetadata:
            return @"Fail to send metadata";
        case FailToUploadFirmware:
            return @"Fail to upload firmware";
        case FailToValidateFirmware:
            return @"Fail to validate firmware";
        case FailToActivateFirmware:
        default:
            return nil;
    }
}

NSString * const WLXNordicUtilitiesErrorDomain = @"ar.com.wolox.WLXNordicUtilitiesError";

NSError * CannotDiscoverDFUDevicesError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(CannotDiscoverDFUDevices) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:CannotDiscoverDFUDevices userInfo:userInfo];
}

NSError * UnsupportedResponseOperationError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(UnsupportedResponseOperation) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:UnsupportedResponseOperation userInfo:userInfo];
}

NSError * AlreadyUploadingFirmwareError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(AlreadyUploadingFirmware) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:AlreadyUploadingFirmware userInfo:userInfo];
}

NSError * FailToStartDFUError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(FailToStartDFU) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToStartDFU userInfo:userInfo];
}

NSError * FailToSendMetadataError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(FailToSendMetadata) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToSendMetadata userInfo:userInfo];
}

NSError * FailToUploadFirmwareError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(FailToUploadFirmware) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToUploadFirmware userInfo:userInfo];
}

NSError * FailToValidateFirmwareError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(FailToValidateFirmware) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToValidateFirmware userInfo:userInfo];
}

NSError * FailToActivateFirmwareError() {
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : getErrorMessage(FailToActivateFirmware) };
    return [NSError errorWithDomain:WLXNordicUtilitiesErrorDomain code:FailToActivateFirmware userInfo:userInfo];
}
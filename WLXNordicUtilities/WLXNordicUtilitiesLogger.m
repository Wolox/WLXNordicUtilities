//
//  WLXNordicUtilitiesLogger.m
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/15/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import "WLXNordicUtilitiesLogger.h"

@implementation WLXNordicUtilitiesLogger

+ (void)setLogLevel:(int)logLevel {
    SEL loggerContextSelector = NSSelectorFromString(@"loggerContext");
    for (Class clazz in [DDLog registeredClasses]) {
        if (![clazz respondsToSelector:loggerContextSelector]) {
            continue;
        }
        
        // Performs loggerContext method on the given class
        int loggerContext;
        NSMethodSignature * signature = [clazz methodSignatureForSelector:loggerContextSelector];
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:loggerContextSelector];
        [invocation setTarget:clazz];
        [invocation invoke];
        [invocation getReturnValue:&loggerContext];
        
        if (loggerContext == WLX_NU_LOG_CONTEXT) {
            [DDLog setLevel:logLevel forClass:clazz];
        }
    }
}

@end
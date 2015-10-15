//
//  WLXNordicUtilitiesLogger.h
//  WLXNordicUtilities
//
//  Created by Guido Marucci Blas on 10/15/15.
//  Copyright © 2015 Wolox. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static int WLXNordicUtilitiesLogLevel = DDLogLevelVerbose;
#endif
#ifdef RELEASE
static int WLXNordicUtilitiesLogLevel = DDLogLevelWarning;
#endif

#define WLX_NU_LOG_CONTEXT 6956968 // WOLOXNU

#define WLXNULogError(frmt, ...) LOG_MAYBE(NO, WLXNordicUtilitiesLogLevel, DDLogFlagError, WLX_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WLXNULogWarn(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, WLXNordicUtilitiesLogLevel, DDLogFlagWarning, WLX_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WLXNULogInfo(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, WLXNordicUtilitiesLogLevel, DDLogFlagInfo, WLX_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WLXNULogDebug(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, WLXNordicUtilitiesLogLevel, DDLogFlagDebug, WLX_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WLXNULogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, WLXNordicUtilitiesLogLevel, DDLogFlagVerbose, WLX_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define WLX_NU_DYNAMIC_LOGGER_METHODS               \
+ (int)ddLogLevel {                                 \
return WLXNordicUtilitiesLogLevel;              \
}                                                   \
\
+ (void)ddSetLogLevel:(int)logLevel {               \
WLXNordicUtilitiesLogLevel = logLevel;          \
}                                                   \
\
+ (int)loggerContext {                              \
return WLX_NU_LOG_CONTEXT;                         \
}

@interface WLXNordicUtilitiesLogger : NSObject

+ (void)setLogLevel:(int)logLevel;

@end
//
//  CSSettings.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 17/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@implementation CurioSettings

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}


- (BOOL) set:(NSString *)serverUrl
      apiKey:(NSString *)apiKey
trackingCode:(NSString *)trackingCode {
    
    if (serverUrl == nil || apiKey == nil || trackingCode == nil) {
        CS_Log_Error(@"Invalid required value(s) to override; %@ %@ %@",serverUrl,apiKey,trackingCode);
        return FALSE;
    }
    
    _serverUrl = serverUrl;
    _apiKey = apiKey;
    _trackingCode = trackingCode;
    
    return TRUE;
}


- (BOOL) set:(NSString *)serverUrl
                   apiKey:(NSString *)apiKey
             trackingCode:(NSString *)trackingCode
           sessionTimeout:(NSNumber *)sessionTimeout
  periodicDispatchEnabled:(NSNumber *)periodicDispatchEnabled
           dispatchPeriod:(NSNumber *)dispatchPeriod
  maxCachedActivitiyCount:(NSNumber *)maxCachedActivityCount
           loggingEnabled:(NSNumber *)logginEnabled
                 logLevel:(NSNumber *)logLevel
registerForRemoteNotifications:(NSNumber *)registerForRemoteNotifications
    notificationTypes:(NSString *)notificationTypes
fetchLocationEnabled:(NSNumber *)fetchLocationEnabled
maxValidLocationTimeInterval:(NSNumber *)maxValidLocationTimeInterval
{
    _sessionTimeout = CS_SET_IF_NOT_NIL(sessionTimeout, _sessionTimeout);
    _periodicDispatchEnabled = CS_SET_IF_NOT_NIL(periodicDispatchEnabled, _periodicDispatchEnabled);
    _dispatchPeriod = CS_SET_IF_NOT_NIL(dispatchPeriod, _dispatchPeriod);
    _maxCachedActivityCount = CS_SET_IF_NOT_NIL(maxCachedActivityCount, _maxCachedActivityCount);
    _loggingEnabled = CS_SET_IF_NOT_NIL(logginEnabled, _loggingEnabled);
    _logLevel = CS_SET_IF_NOT_NIL(logLevel, _logLevel);
    _registerForRemoteNotifications = CS_SET_IF_NOT_NIL(registerForRemoteNotifications, _registerForRemoteNotifications);
    _notificationTypes = CS_SET_IF_NOT_NIL(notificationTypes, _notificationTypes);
    _fetchLocationEnabled =  CS_SET_IF_NOT_NIL(fetchLocationEnabled, _fetchLocationEnabled);
    _maxValidLocationTimeInterval =  CS_SET_IF_NOT_NIL(maxValidLocationTimeInterval, _maxValidLocationTimeInterval);
    
    return [self set:serverUrl apiKey:apiKey trackingCode:trackingCode];
}


- (void) readBundleSettings {
    
    NSDictionary *settings = nil;
    
    for (NSBundle *bundle in [NSBundle allBundles]) {
        
        settings = [[bundle infoDictionary] objectForKey:CS_OPT_SETTINGS_DICT_HEADER];
        if (settings != nil){
            [self set:[settings objectForKey:CS_OPT_SKEY_SERVER_URL]
               apiKey:[settings objectForKey:CS_OPT_SKEY_API_KEY]
         trackingCode:[settings objectForKey:CS_OPT_SKEY_TRACKING_CODE]
       sessionTimeout:[settings objectForKey:CS_OPT_SKEY_SESSION_TIMEOUT]
periodicDispatchEnabled:[settings objectForKey:CS_OPT_SKEY_PERIODIC_DISPATCH_ENABLED]
       dispatchPeriod:[settings objectForKey:CS_OPT_SKEY_DISPATCH_PERIOD]
maxCachedActivitiyCount:[settings objectForKey:CS_OPT_SKEY_MAX_CACHED_ACTIVITY_COUNT]
       loggingEnabled:[settings objectForKey:CS_OPT_SKEY_LOGGING_ENABLED]
             logLevel:[settings objectForKey:CS_OPT_SKEY_LOGGING_LEVEL]
registerForRemoteNotifications:[settings objectForKey:CS_OPT_SKEY_REGISTER_FOR_REMOTE_NOTIFICATIONS]
    notificationTypes:[settings objectForKey:CS_OPT_SKEY_NOTIFICATION_TYPES]
 fetchLocationEnabled:[settings objectForKey:CS_OPT_SKEY_FETCH_LOCATION_ENABLED]
maxValidLocationTimeInterval:[settings objectForKey:CS_OPT_SKEY_MAX_VALID_LOCATION_TIME_INTERVAL]
             ];
            break;
        }
    }
}

- (id) init {
    if ((self = [super init])) {
        
        // Defaults
        
        _sessionTimeout = [NSNumber numberWithInt:30];
        _periodicDispatchEnabled = CS_NSN_TRUE;
        _dispatchPeriod = [NSNumber numberWithInt:5];
        _maxCachedActivityCount = [NSNumber numberWithInt:100];
        _loggingEnabled = CS_NSN_TRUE;
        _logLevel = [NSNumber numberWithInt:CSLogLevelError];
        _registerForRemoteNotifications = CS_NSN_TRUE;
        _notificationTypes = CURNotificationTypes;
        _fetchLocationEnabled = CS_NSN_TRUE;
        _maxValidLocationTimeInterval = [NSNumber numberWithDouble:600];
        
        [self readBundleSettings];
    }
    return self;
}


@end

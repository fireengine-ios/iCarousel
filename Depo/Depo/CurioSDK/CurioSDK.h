//
//  CurioSDK.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 16/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//


#ifndef CS_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define CS_INSTANCETYPE instancetype
#else
#define CS_INSTANCETYPE id
#endif
#endif


#define CURIO_SDK_VERSION @"1.2.4"

// Notification names

#define CS_NOTIF_NEW_ACTION @"CS_NOTIF_NEW_ACTION"
#define CS_NOTIF_REGISTERED_NEW_SESSION_CODE @"CS_NOTIF_REGISTERED_NEW_SESSION_CODE"
#define CS_NOTIF_UNREGISTER @"CS_NOTIF_UNREGISTER"
#define CS_NOTIF_CUSTOM_ID_SET @"CS_NOTIF_CUSTOM_ID_SET"

// Optional parameters

#define CS_OPT_USER_AGENT [NSString stringWithFormat:@"IOS CurioSDK v%@",CURIO_SDK_VERSION]

#define CS_OPT_MAX_ACTION_TO_READ_PER_POST 250

#define CS_OPT_MAX_POST_OFFICE_RETRY_COUNT 5

#define CS_OPT_NETWORK_CHECK_HOST @"turkcell.com.tr"

#define CS_OPT_SETTINGS_DICT_HEADER @"CurioSDK"
#define CS_OPT_SKEY_SERVER_URL @"ServerURL"
#define CS_OPT_SKEY_API_KEY @"ApiKey"
#define CS_OPT_SKEY_TRACKING_CODE @"TrackingCode"
#define CS_OPT_SKEY_SESSION_TIMEOUT @"SessionTimeout"
#define CS_OPT_SKEY_PERIODIC_DISPATCH_ENABLED @"PeriodicDispatchEnabled"
#define CS_OPT_SKEY_DISPATCH_PERIOD @"DispatchPeriod"
#define CS_OPT_SKEY_MAX_CACHED_ACTIVITY_COUNT @"MaxCachedActivityCount"
#define CS_OPT_SKEY_LOGGING_ENABLED @"LoggingEnabled"
#define CS_OPT_SKEY_LOGGING_LEVEL @"LogLevel"
#define CS_OPT_SKEY_REGISTER_FOR_REMOTE_NOTIFICATIONS @"RegisterForRemoteNotifications"
#define CS_OPT_SKEY_NOTIFICATION_TYPES @"NotificationTypes"
#define CS_OPT_SKEY_FETCH_LOCATION_ENABLED @"FetchLocationEnabled"
#define CS_OPT_SKEY_MAX_VALID_LOCATION_TIME_INTERVAL @"MaxValidLocationTimeInterval"
#define CS_OPT_DB_FILE_NAME @"curio.db"

#define CS_SERVER_URL_SUFFIX_SESSION_START  @"/visit/create"
#define CS_SERVER_URL_SUFFIX_SESSION_END  @"/visit/end"
#define CS_SERVER_URL_SUFFIX_SCREEN_START @"/hit/create"
#define CS_SERVER_URL_SUFFIX_SCREEN_END  @"/hit/end"
#define CS_SERVER_URL_SUFFIX_SEND_EVENT  @"/event/create"
#define CS_SERVER_URL_SUFFIX_END_EVENT  @"/event/end"
#define CS_SERVER_URL_SUFFIX_PERIODIC_BATCH @"/batch/create"
#define CS_SERVER_URL_SUFFIX_OFFLINE_CACHE  @"/offline/create"
#define CS_SERVER_URL_SUFFIX_PUSH_DATA @"/visitor/setPushData"
#define CS_SERVER_URL_SUFFIX_LOCATION_DATA @"/location/set"
#define CS_SERVER_URL_SUFFIX_UNREGISTER @"/visitor/unregister"
#define CS_SERVER_URL_SUFFIX_PUSH_HISTORY @"/pushHistory/get"
#define CS_SERVER_URL_SUFFIX_SET_USER_TAGS @"/visitor/setUserTag"
#define CS_SERVER_URL_SUFFIX_GET_USER_TAGS @"/visitor/getVisitorProfileTags"

#define CS_HTTP_PARAM_HIT_CODE @"hitCode"
#define CS_HTTP_PARAM_EVENT_CODE @"eventCode"
#define CS_HTTP_PARAM_TRACKING_CODE @"trackingCode"
#define CS_HTTP_PARAM_VISITOR_CODE @"visitorCode"
#define CS_HTTP_PARAM_PATH @"path"
#define CS_HTTP_PARAM_SCREEN_WIDTH @"screenWidth"
#define CS_HTTP_PARAM_SCREEN_HEIGHT @"screenHeight"
#define CS_HTTP_PARAM_ACTIVITY_WIDTH @"activityWidth"
#define CS_HTTP_PARAM_ACTIVITY_HEIGHT @"activityHeight"
#define CS_HTTP_PARAM_OS_TYPE @"osType"
#define CS_HTTP_PARAM_OS_VERSION @"osVer"
#define CS_HTTP_PARAM_SDK_VERSION @"curioSdkVer"
#define CS_HTTP_PARAM_APP_VERSION @"appVer"
#define CS_HTTP_PARAM_BRAND @"brand"
#define CS_HTTP_PARAM_MODEL @"model"
#define CS_HTTP_PARAM_SESSION_CODE @"sessionCode"
#define CS_HTTP_PARAM_EVENT_KEY @"eventKey"
#define CS_HTTP_PARAM_EVENT_VALUE @"eventValue"
#define CS_HTTP_PARAM_EVENT_DURATION @"eventDuration"
#define CS_HTTP_PARAM_SIM_OPERATOR @"simOperator"
#define CS_HTTP_PARAM_SIM_COUNTRY_ISO @"simOpCountry"
#define CS_HTTP_PARAM_NETWORK_OPERATOR_NAME @"networkOpName"
#define CS_HTTP_PARAM_INTERNET_CONN_TYPE @"connType"
#define CS_HTTP_PARAM_LANG @"lang"
#define CS_HTTP_PARAM_API_KEY @"apiKey"
#define CS_HTTP_PARAM_CURIO_SDK_VERSION @"curioSdkVer"
#define CS_HTTP_PARAM_SESSION_TIMEOUT @"sessionTimeout"
#define CS_HTTP_PARAM_TIME @"time"
#define CS_HTTP_PARAM_JSON_DATA @"data"
#define CS_HTTP_PARAM_TITLE @"pageTitle"
#define CS_HTTP_PARAM_BATTERY_STATE @"batteryState"
#define CS_HTTP_PARAM_BATTERY_LEVEL @"batteryLevel"
#define CS_HTTP_PARAM_BLUETOOTH_STATE @"bluetooth"
#define CS_HTTP_PARAM_TOTAL_STORAGE_SPACE @"totalStorageSpace"
#define CS_HTTP_PARAM_TOTAL_FREE_STORAGE_SPACE @"storage"

#define CS_CUSTOM_VAR_SCREENCLASS @"screenClass"
#define CS_CUSTOM_VAR_EVENTCLASS @"eventClass"

#define CS_HTTP_JSON_VARNAME_TYPE @"type"
#define CS_HTTP_JSON_VARNAME_TIMESTAMP @"timestamp"
#define CS_HTTP_JSON_VARNAME_PAGETITLE @"pageTitle"
#define CS_HTTP_JSON_VARNAME_PATH @"path"
#define CS_HTTP_JSON_VARNAME_HITCODE @"hitCode"
#define CS_HTTP_JSON_VARNAME_EVENTCODE @"eventCode"
#define CS_HTTP_JSON_VARNAME_SESSIONCODE @"sessionCode"
#define CS_HTTP_JSON_VARNAME_EVENT_KEY @"eventKey"
#define CS_HTTP_JSON_VARNAME_EVENT_VALUE @"eventValue"
#define CS_HTTP_JSON_VARNAME_EVENT_DURATION @"eventDuration"

// Shortcuts

#define CS_CONST_AL_SC @"ALIVE_SCREENS"
#define CS_CONST_AL_EV @"ALIVE_EVENTS"

#define CS_CONST_DEV_TOK @"DEVICE_TOKEN"

#define CS_NSN_TRUE [NSNumber numberWithBool:TRUE]
#define CS_NSN_FALSE [NSNumber numberWithBool:FALSE]

#define CS_NSN_IS_TRUE(val) (val.intValue == CS_NSN_TRUE.intValue)

#define CS_SET_IF_NOT_NIL(var,orig) (var != nil ? var : orig)
#define CS_NULL_IF_NIL(var) CS_SET_IF_NOT_NIL(var,@"NULL")
#define CS_ZERO_IF_NIL(var) CS_SET_IF_NOT_NIL(var,[NSNumber numberWithInt:0])

#define CS_RM_STR_NEWLINE(obj) [[NSString stringWithFormat:@"%@", obj] stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"]

#define CS_Log_Level [[[CurioSettings shared] logLevel] intValue]
#define CS_Log_Enabled CS_NSN_IS_TRUE([[CurioSettings shared] loggingEnabled])
#define CS_Log_Error(fmt, ...)  if (CS_Log_Enabled) { NSLog((@"CurioSDK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }
#define CS_Log_Warning(fmt, ...)  if (CS_Log_Enabled && (CS_Log_Level == CSLogLevelInfo || CS_Log_Level == CSLogLevelDebug || CS_Log_Level == CSLogLevelWarning )) { NSLog((@"CurioSDK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }
#define CS_Log_Info(fmt, ...)  if (CS_Log_Enabled && (CS_Log_Level == CSLogLevelInfo || CS_Log_Level == CSLogLevelDebug)) { NSLog((@"CurioSDK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }
#define CS_Log_Debug(fmt, ...)  if (CS_Log_Enabled && CS_Log_Level == CSLogLevelDebug) { NSLog((@"CurioSDK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

#define CS_AS_STRING(val) [NSString stringWithFormat:@"%s",val]
#define CS_INT_AS_STRING(val) [NSString stringWithFormat:@"%i",val]
#define CS_DOUBLE_AS_STRING(val) [NSString stringWithFormat:@"%lf",val]
#define CS_LLD_AS_STRING(val) [NSString stringWithFormat:@"%lld",val]

#define CS_SET_DICT_IF_NOT_NIL(dict,val,key) if (val != nil) [dict setObject:val forKey:key];

#import <UIKit/UIKit.h>

#import "CurioConstants.h"
#import "CurioReachabilityEx.h"
#import "CurioSettings.h"
#import "CurioAction.h"
#import "CurioDB.h"
#import "CurioDBToolkit.h"
#import "CurioUtil.h"
#import "CurioNetwork.h"
#import "CurioPostOffice.h"
#import "CurioActionToolkit.h"
#import "CurioPushData.h"
#import "CurioNotificationManager.h"
#import "CurioLocationManager.h"
#import "CurioLocationData.h"
#import "CurioResourceUtil.h"


__TVOS_UNAVAILABLE
@protocol CurioSDKDelegate <NSObject>
- (void) unregisteredFromNotificationServer:(NSDictionary *)responseDictionary;
- (void) customIDSent:(NSDictionary *)responseDictionary;
@end


@interface CurioSDK : NSObject {
    
    NSOperationQueue *curioQueue;
    NSOperationQueue *curioActionQueue;
    BOOL appWasInBackground;
}

@property (nonatomic) BOOL sessionCodeRegisteredOnServer;
@property (strong, nonatomic) NSMutableDictionary *memoryStore;
@property (strong, nonatomic) NSMutableArray *aliveScreens;
@property (strong, nonatomic) NSMutableArray *aliveEvents;
@property (strong, nonatomic) NSDictionary *appLaunchOptions;

//Custom Id parameter.
@property (strong, nonatomic) NSString *customId;

@property (assign, nonatomic) NSUInteger retryCount;


@property (assign,nonatomic) id<CurioSDKDelegate> delegate __TVOS_UNAVAILABLE;


/**
    Returns shared instance of CurioSDK
 
    @return CurioSDK shared instance
 */
+ (CS_INSTANCETYPE) shared;


/**
    Initializes CurioSDK object
 
    @return Initialized CurioSDK object
 */
- (id) init;

/**
    Returns session code if already been set otherwise generates new one
 
    @return Dynamically created sessionCode
 */
- (NSString *) sessionCode;

/**
 *  Sends event-key and event-value back to Curio Server
 *
 *  @param eventKey   Key of the event
 *  @param eventValue Value of the event
 *
 */
- (void) sendEvent:(NSString *) eventKey eventValue:(NSString *) eventValue;

/**
 *  Sends event-key and event-value back to Curio Server
 *
 *  @param eventKey   Key of the event
 *  @param eventValue Value of the event
 *
 */
- (void) endEvent:(NSString *) eventKey eventValue:(NSString *) eventValue eventDuration:(NSUInteger) eventDuration;
/**
 *  Send endScreen message back to Curio server
 *
 *  @param screenClass Class type of the screen mentioned
 *
 *  @return True, if everything went well
 */
- (void) endScreen:(Class) screenClass ;

/**
 *  Sends startScreen message back to Curio server
 *
 *  @param screenClass Class type of the screen mentioned
 *  @param title       Screen title
 *  @param path        Path description
 *
 */
- (void) startScreen:(Class) screenClass title:(NSString *) title path:(NSString *) path;


/**
 *  Ends current session set with current application
 *
 */
- (void) endSession;

/**
    Starts Curio session.
 
 */
- (void) startSession:(NSDictionary *)appLaunchOptions;

/*
 
 ServerURL: [Required] Curio server URL, can be obtained from Turkcell.
 
 ApiKey: [Required] Application specific API key, can be obtained from Turkcell.
 
 TrackingCode: [Required] Application specific tracking code, can be obtained from Turkcell.
 
 SessionTimeout: [Optional] Session timeout in minutes. Default is 30 minutes but it's highly recommended to change this value acording to the nature of your application. Specifiying a correct session timeout value for your application will increase the accuracy of the analytics data.
 
 PeriodicDispatchEnabled: [Optional] Periodic dispatch is enabled if true. Default is false.
 
 DispatchPeriod: [Optional] If periodic dispatch is enabled, this parameter configures dispatching period in minutes. Deafult is 5 minutes. Note: This parameter cannot be greater than session timeout value.
 
 MaxCachedActivityCount: [Optional] Max. number of user activity that Curio library will remember when device is not connected to the Internet. Default is 1000. Max. value can be 4000.
 
 LoggingEnabled: [Optional] All of the Curio logs will be disabled if this is false. Default is true.
 
 LogLevel: [Optional] Contains level of the print-out logs. 0 - Error, 1 - Warning, 2 - Info, 3 - Debug. Default is 0 (Error).
 
 RegisterForRemoteNotifications: If enabled, then Curio SDK will automatically register for remote notifications for types defined in "NotificationTypes" parameter.
 
 NotificationTypes: Notification types to register; available values: Sound, Badge, Alert
 
 FetchLocationEnabled: [Optional] If enabled, the current location of the device will be tracked while using the application. Default is true. The accuracy of recent location is validated using MaxValidLocationTimeInterval. Location tracking stops when the accurate location is found according to the needs. For further location tracking you can use [[CurioSDK shared] sendLocation] method. In order to track locations in iOS8 NSLocationWhenInUseUsageDescription must be implemented in Info.plist file.
 
 MaxValidLocationTimeInterval: [Optional] Default is 600 seconds. The accuracy of recent location is validated using this parameter. Location tracking continues until it reaches to a valid location time interval.
 
 delegate: If you are using "CurioSDKDelegate" protocol, you can set this parameter with your class reference. "CurioSDKDelegate" protocol provides callbacks for responses from "unregisterFromNotificationServer" and "sendCustomId" methods.
 
*/

/*! Starts Curio session.
 * \param startSession serverUrl [Required] Curio server URL, can be obtained from Turkcell.
 * \param apiKey [Required] Application specific API key, can be obtained from Turkcell.
 * \param trackingCode [Required] Application specific tracking code, can be obtained from Turkcell.
 * \param sessionTimeout [Optional] Session timeout in minutes. Default is 30 minutes but it's highly recommended to change this value acording to the nature of your application. Specifiying a correct session timeout value for your application will increase the accuracy of the analytics data.
 * \param periodicDispatchEnabled [Optional] Periodic dispatch is enabled if true. Default is false.
 * \param dispatchPeriod [Optional] If periodic dispatch is enabled, this parameter configures dispatching period in minutes. Deafult is 5 minutes. Note: This parameter cannot be greater than session timeout value.
 * \param maxCachedActivitiyCount [Optional] Max. number of user activity that Curio library will remember when device is not connected to the Internet. Default is 1000. Max. value can be 4000.
 * \param loggingEnabled [Optional] All of the Curio logs will be disabled if this is false. Default is true.
 * \param logLevel [Optional] Contains level of the print-out logs. 0 - Error, 1 - Warning, 2 - Info, 3 - Debug. Default is 0 (Error).
 * \param registerForRemoteNotifications If enabled, then Curio SDK will automatically register for remote notifications for types defined in "NotificationTypes" parameter.
 * \param notificationTypes Notification types to register; available values: Sound, Badge, Alert
 * \param fetchLocationEnabled [Optional] If enabled, the current location of the device will be tracked while using the application. Default is true. The accuracy of recent location is validated using MaxValidLocationTimeInterval. Location tracking stops when the accurate location is found according to the needs. For further location tracking you can use [[CurioSDK shared] sendLocation] method. In order to track locations in iOS8 NSLocationWhenInUseUsageDescription must be implemented in Info.plist file.
 * \param maxValidLocationTimeInterval [Optional] Default is 600 seconds. The accuracy of recent location is validated using this parameter. Location tracking continues until it reaches to a valid location time interval.
 * \param delegate If you are using "CurioSDKDelegate" protocol, you can set this parameter with your class reference. "CurioSDKDelegate" protocol provides callbacks for responses from "unregisterFromNotificationServer" and "sendCustomId" methods.
 * \param appLaunchOptions Set this with Appdelegate's appLaunchOptions. It is used for tracking notifications.
 */

- (void) startSession:(NSString *)serverUrl
               apiKey:(NSString *)apiKey
         trackingCode:(NSString *)trackingCode
       sessionTimeout:(int)sessionTimeout
periodicDispatchEnabled:(BOOL)periodicDispatchEnabled
       dispatchPeriod:(int)dispatchPeriod
maxCachedActivitiyCount:(int)maxCachedActivityCount
       loggingEnabled:(BOOL)logginEnabled
             logLevel:(int)logLevel
registerForRemoteNotifications:(BOOL)registerForRemoteNotifications
    notificationTypes:(NSString *) notificationTypes
 fetchLocationEnabled:(BOOL)fetchLocationEnabled
maxValidLocationTimeInterval:(double)maxValidLocationTimeInterval
             delegate:(id<CurioSDKDelegate>)delegate
     appLaunchOptions:(NSDictionary *)appLaunchOptions __TVOS_UNAVAILABLE;

/**
    Starts Curio session.
 
    @return True, if everything went well.
 */
- (void) startSession:(NSString *)serverUrl
               apiKey:(NSString *)apiKey
         trackingCode:(NSString *)trackingCode
     appLaunchOptions:(NSDictionary *)appLaunchOptions;


/**
 *    Starts Curio session without notification features.
 */

-(void)startSession:(NSString *)serverUrl
             apiKey:(NSString *)apiKey
       trackingCode:(NSString *)trackingCode
     sessionTimeout:(int)sessionTimeout
periodicDispatchEnabled:(BOOL)periodicDispatchEnabled
     dispatchPeriod:(int)dispatchPeriod
maxCachedActivitiyCount:(int)maxCachedActivityCount
     loggingEnabled:(BOOL)logginEnabled
           logLevel:(int)logLevel
fetchLocationEnabled:(BOOL)fetchLocationEnabled
maxValidLocationTimeInterval:(double)maxValidLocationTimeInterval
   appLaunchOptions:(NSDictionary *)appLaunchOptions;

/**
 *  Re-generates session code for further actions
 */
- (void) reGenerateSessionCode;


/**
 * Unregisters this device from push notification server.
 */
- (void) unregisterFromNotificationServer __TVOS_UNAVAILABLE;

/**
 * Sends custom id to push notification server manually.
 */
- (void) sendCustomId:(NSString *)theCustomId __TVOS_UNAVAILABLE;

/**
 *
 */
- (void) sendLocation;

/**
 *
 */
- (void)getNotificationHistoryWithPageStart:(NSInteger)pageStart
                               rows:(NSInteger)rows
                                 success:(void(^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure __TVOS_UNAVAILABLE;

/**
 *
 */
-(void)sendUserTags:(NSDictionary *)tags;
/**
 *
 */
-(void)getUserTagsWithSuccess:(void(^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure;


@end

//
//  CSSettings.h
//  CurioSDK
//
//  Created by Harun Esur on 17/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CSLogLevel) {
    CSLogLevelError = 0,
    CSLogLevelWarning = 1,
    CSLogLevelInfo = 2,
    CSLogLevelDebug = 3
};

@interface CurioSettings : NSObject

/**
    Curio server URL, can be obtained from Turkcell.
 */
@property (strong, nonatomic) NSString *serverUrl;

/**
    Application specific API key, can be obtained from Turkcell.
 */
@property (strong, nonatomic) NSString *apiKey;

/**
    Application specific tracking code, can be obtained from Turkcell.
 */
@property (strong, nonatomic) NSString *trackingCode;

/**
    Session timeout in minutes.
 
    Default is 30 minutes but it's highly recommended to change this value 
    according to the nature of your application. Specifiying a correct session
    timeout value for your application will increase the accuracy of the analytics data.
 */
@property (strong, nonatomic) NSNumber *sessionTimeout;

/**
    Periodic dispatch is enabled if true. 
 
    Default is false.
 */
@property (strong, nonatomic) NSNumber *periodicDispatchEnabled;

/**
    If periodic dispatch is enabled, this parameter configures dispatching period in minutes.
 
    Default is 5 minutes
 */
@property (strong, nonatomic) NSNumber *dispatchPeriod;

/**
    Max. number of user activity that Curio library will remember 
    when device is not connected to the Internet.
 
    Default is 1000.
 */
@property (strong, nonatomic) NSNumber *maxCachedActivityCount;


/**
    All of the Curio logs will be disabled if this is false. 
 
    Default is true.
 */
@property (strong, nonatomic) NSNumber *loggingEnabled;


/**
    Contains level of the print-out logs. 
 
    0 - Error, 1 - Warning, 2 - Info, 3 - Debug
 
    Default is 1.
 */
@property (strong, nonatomic) NSNumber *logLevel;



/**
    If enabled, then Curio SDK will automatically register for remote notifications for all types
 
    Default is true.
 */
@property (strong, nonatomic) NSNumber *registerForRemoteNotifications;


/**
    Notification types to register for.
 
    Every type can be typed by using keywords Sound, Badge and Alert.
 
    Keywords should be seperated with commas. Any order is accepted.
 
 
    Default is "Sound,Badge,Alert"
 */
@property (strong ,nonatomic) NSString *notificationTypes;

/**
 Returns shared instance of CSSettings
 
 @return CSSettings shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 Initializes CSSettings object
 
 @return Initialized CSSettings object
 */
- (id) init;


/**
 Overrides required settings values with given ones
 
 @return True if required values are ok FALSE if not
 */
- (BOOL)        set:(NSString *)serverUrl
             apiKey:(NSString *)apiKey
       trackingCode:(NSString *)trackingCode;

/**
 Overrides all settings values with given ones
 
 @return True if required values are ok FALSE if not
 */
- (BOOL)                set:(NSString *)serverUrl
                     apiKey:(NSString *)apiKey
               trackingCode:(NSString *)trackingCode
             sessionTimeout:(NSNumber *)sessionTimeout
    periodicDispatchEnabled:(NSNumber *)periodicDispatchEnabled
             dispatchPeriod:(NSNumber *)dispatchPeriod
    maxCachedActivitiyCount:(NSNumber *)maxCachedActivityCount
             loggingEnabled:(NSNumber *)logginEnabled
                   logLevel:(NSNumber *)logLevel
registerForRemoteNotifications:(NSNumber *)registerForRemoteNotifications
    notificationTypes:(NSString *) notificationTypes;

/**
 Reads settings values from *-Info.plist file
 
 @return If everything goes fine then TRUE otherwise FALSE
 */
- (BOOL) readBundleSettings;


@end

//
//  MPush.h
//  МPush
//
//  Created by Alex on 6/8/15.
//  Copyright (c) 2015 МPush. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	Notification name, which will be sent when device registered in the server.
 */
extern NSString *const МPushDeviceRegistrationNotification;

@interface MPush : NSObject

/**
 *  Set external id of device which can be used then on platform to target devices
 */
+ (void)setExternalId:(NSString *)externalId;

/**
 *  Check sandbox mode or not. Call singletone and check sandbox mode in it.
 *  Sandbox mode can switched in plist. Key for it: "MenloPushSandboxMode".
 */
+ (BOOL)isSandboxModeOn;

/**
 *	Switches on/off in-app messages.
 *  By default is off.
 */
+ (void)setInAppMessageEnabled:(BOOL)enabled;

/**
 *  Switches on/off use location manager in the app.
 *  By default is on.
 */
+ (void)setLocationEnabled:(BOOL)locationEnabled;

/**
 *  If set to YES, application will ask about location permissions on first launch.
 *  If set to NO, you have manually ask about location permissions anytime you need.
 *  By default is YES.
 *  Has no affect is locationEnabled is set to NO.
 */
+ (void)setAsksForLocationPermissions:(BOOL)asksForLocationPermissions;

/**
 *	Should or not application reset a badge icon.
 */
+ (void)setShouldWipeBadgeNumber:(BOOL)shouldWipeBadgeNumber;
+ (BOOL)shouldWipeBadgeNumber;

/**
 *	Register current application and this lib to receive notifications. You should call it instead of [UIApplication registerForRemoteNotificationTypes:].
 * Uses UIRemoteNotificationType or UIUserNotificationType for ios8
 */
+ (void)registerForRemoteNotificationTypes:(NSInteger)types;

/**
 * Unregister current application and this lib to receive notifications
 */
+ (void)unregisterForRemoteNotifications;

/**
 *	Creates and runs lib. You should call it in [UIApplication applicationDidFinishLaunchingWithOptions:] method after configuring this library.
 */
+ (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *	You should call it when application calls [UIApplication application: didRegisterForRemoteNotificationsWithDeviceToken:] method.
 */
+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 *	You should call it when your app receives notification and calls -applicationDidReceiveRemoteNotification: method. Lib shows alert with notification text and mark push as read on the platform.
 *  Alert is not shown if showAlert is set to NO.
 */
+ (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo showAlert:(BOOL)showAlert;

/**
 *	You should call it when your app receives notification and calls -applicationDidReceiveRemoteNotification: method. Lib shows alert with notification text and mark push as read on the platform.
 */
+ (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 *	Does nothing.
 */
+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 *	Returns version of the lib.
 */
+ (NSString *)version;

/**
 *	Returns dictionary with device token and device id.
 *  MPushDeviceID - key for Menlo device id.
 *  deviceToken - key for token.
 *  deviceId - key for device IDFV.
 */
+ (NSDictionary *)deviceInfo;

/**
 *	Calls "eventHit" api method.
 */
+ (void)hitEvent:(NSString *)event;

/**
 *	Calls "tagHit" api method.
 */
+ (void)hitTag:(NSString *)tag;

/**
 *  Calls "tagHit" api method with value
 */
+ (void)hitTag:(NSString *)tag withValue:(NSString *)value;

/**
 *	Calls "impressionHit" api method.
 */
+ (void)hitImpression:(NSString *)impression;

/**
 *  If set to YES, application will start to batch tag hits and send it on change of application state or on call sendTags method.
 *  If set to NO, application will send tag immediately after tag hit.
 *  By default is NO.
 */
+ (void)setTagsBatchingEnabled:(BOOL)tagsBatchingEnabled;

/**
 *  Send tags batch. You should use this method only if tags batching is enabled.
 */
+ (void)sendTags;

/**
 *  If set to YES, application will start to batch impression hits and send it on change of application state or on call sendImpressions method.
 *  If set to NO, application will send impression immediately after impression hit.
 *  By default is NO.
 */
+ (void)setImpressionsBatchingEnabled:(BOOL)impressionsBatchingEnabled;

/**
 *  Send impressions batch. You should use this method only if impressions batching is enabled.
 */
+ (void)sendImpressions;

/**
 *  Set a limit for a maximum number of stored tags, impressions and sessions
 */
+ (void)setTagsStoreLimit:(NSUInteger *)limit;
+ (void)setImpressionsStoreLimit:(NSUInteger *)limit;
+ (void)setSessionsStoreLimit:(NSUInteger *)limit;

/**
 *	Used to get a list of push notifications for current device
 */
+ (void)getPushNotificationsOffset:(NSUInteger)offset limit:(NSUInteger)limit completion:(void(^)(NSArray *pushList, NSError *error))completion;

/**
 *	Used to manually mark a push as read.
 */
+ (void)markPushAsRead:(NSString *)actionId;

/**
 *	Shows LibPushListViewController like modal view controller. Shows Inbox screen.
 */
+ (void)showPushListController;

/**
 *  Turn on/off showing of debug logs
 */
+ (void)setShouldShowDebugLogs:(BOOL)log;

/**
 *  Change server url at runtime
 */
+ (void)setServerURL:(NSString *)url;

/**
 *  Change app key at runtime
 */
+ (void)setAppKey:(NSString *)appKey;

/**
 *  Certificate pinning
 */
+ (void)setServerExpectedCertificate:(NSString *)certDataString;
+ (void)setServerExpectedCertificateFromFile:(NSString *)filePath;
@end


/**
 * Model for LibPushListViewController. When server returns pushList then list is parsed to array of models.
 */
@interface MPushModel : NSObject

@property (nonatomic, readonly) NSDate      *createDate;
@property (nonatomic, readonly) NSString    *pushId;
@property (nonatomic, readonly) NSString    *locationId;
@property (nonatomic, readonly) NSString    *alert;
@property (nonatomic, readonly) NSInteger   badge;
@property (nonatomic, readonly) NSString    *messageId;
@property (nonatomic, readonly) NSString    *url;
@property (nonatomic, readonly) BOOL        shouldOpenInApp;
@property (nonatomic, assign)   BOOL        isRead;
@property (nonatomic, readonly) NSDictionary *customPayload;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

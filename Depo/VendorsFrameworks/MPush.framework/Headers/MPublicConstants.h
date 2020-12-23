//
//  MPublicConstants.h
//  XPush
//
//  Created by Vlad Soroka on 7/18/17.
//  Copyright © 2017 XPush. All rights reserved.
//

#ifndef MPublicConstants_h
#define MPublicConstants_h

@class MMessageResponse;
@class MMessage;

/**
 *	Notification name, which will be sent when device registered in the server.
 */
extern NSString * _Nonnull const MPushDeviceRegistrationNotification;

/**
 *	Notification name, which will be sent when message response received
 */
extern NSString * _Nonnull const MPushMessageResponseReceiveNotification __attribute__((deprecated("Consider switching to block based notification that are safer to use. ")));

/**
 *	Notification name, which will be sent when inbox badge has changed
 */
extern NSString * _Nonnull const MPushInboxBadgeChangeNotification;

typedef void (^MMessageCompletionBlock)();

/**
 * Callback you'll receive upon any interaction with PushNotification. If you want to leverage background processing with push notification consider using |XPContinousMessageInteractionCallback|
 */
typedef void(^MMessageInteractionCallback)(MMessageResponse* _Nonnull x);

/**
 * Callback you'll receive upon any interaction with PushNotification that requires background processing.
 */
typedef void(^MContinousMessageInteractionCallback)(MMessageResponse* _Nonnull x,
                                                     MMessageCompletionBlock _Nonnull callback);

/**
 *  Callback you'll receive upon deeplink interaction happens
 */
typedef void(^MDeeplinkCallback)(NSString* _Nonnull x);

/**
 *
 */
typedef NS_ENUM(NSInteger, MActionType) {
 
    /**
     * User interacted with notification by clicking on it
     */
    MActionType_Click,
    
    /**
     * Notification was delivered to your application and some UI could have been shown. User has not interacted with notification in any way yet
     */
    MActionType_Present,
    
    /**
     * Notification was delivered to your application, but the user dismissed it
     */
    MActionType_Dismiss,
    
};

/**
 * Available message types
 */
typedef NS_ENUM(NSInteger, MMessageType) {
    
    /**
     * Push message
     */
    MMessageType_Push,
    
    /**
     * Inbox message
     */
    MMessageType_Inbox,
    
    /**
     * In-app message
     */
    MMessageType_Inapp
    
};

/**
 * Available notification options
 */
typedef NS_OPTIONS(NSInteger, MNotificationType) {
  
    MNotificationType_None  = 0,
    
    MNotificationType_Alert = 1 << 0,
    
    MNotificationType_Sound = 1 << 1,
    
    MNotificationType_Badge = 1 << 2
    
};

/**
 * You can provide different behaviours for showing foreground push notification
 */
typedef MNotificationType(^MForegroundNotificationOptions)(MMessage* _Nonnull x);

#endif /* MPublicConstants_h */

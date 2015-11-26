//
//  CurioNotificationManager.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 15/11/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

__TVOS_UNAVAILABLE
@interface CurioNotificationManager : NSObject
{
    NSOperationQueue *curioNotificationQueue;
}

@property (strong, nonatomic) NSString *deviceToken;

/**
 Returns shared instance of CSSettings
 
 @return CSSettings shared instance
 */
+ (CS_INSTANCETYPE) shared __TVOS_UNAVAILABLE;

/**
 
    Registers app for remote notification retrieval
 
 */
- (void) registerForNotifications __TVOS_UNAVAILABLE;

/**
 
    Notifies Curio SDK for registered notification state with device token.
 
 */
- (void) didRegisteredForNotifications:(NSData *)deviceToken __TVOS_UNAVAILABLE;

/**
 
    Notifies Curio SDK for received notification
 
 */
- (void) didReceiveNotification:(NSDictionary *)userInfo __TVOS_UNAVAILABLE;


/**
 * Sends push notification related data (device token, custom id, push message id) to server.
 */
- (void) sendPushData:(NSDictionary *)userInfo;


@end

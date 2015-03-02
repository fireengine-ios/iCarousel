//
//  CurioNotificationManager.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 15/11/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurioNotificationManager : NSObject
{
    NSOperationQueue *curioNotificationQueue;
}

@property (strong, nonatomic) NSString *deviceToken;

/**
 Returns shared instance of CSSettings
 
 @return CSSettings shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 
    Registers app for remote notification retrieval
 
 */
- (void) registerForNotifications;

/**
 
    Notifies Curio SDK for registered notification state with device token.
 
 */
- (void) didRegisteredForNotifications:(NSData *)deviceToken;

/**
 
    Notifies Curio SDK for received notification
 
 */
- (void) didReceiveNotification:(NSDictionary *)userInfo;

/**
 * Unregister from remote notification server using custom Id.
 */
- (void) unregister;


/**
 * Sends push notification related data (device token, custom id, push message id) to server.
 */
- (void) sendPushData:(NSDictionary *)userInfo;


@end

//
//  CurioNotificationManager.h
//  CurioSDK
//
//  Created by Harun Esur on 15/11/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurioNotificationManager : NSObject
{
    NSOperationQueue *curioNotificationQueue;
}

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

@end

//
//  CurioLocationManager.h
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 5.02.2015.
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "CurioSDK.h"
#import <CoreLocation/CoreLocation.h>

@interface CurioLocationManager : NSObject
{
    NSOperationQueue *curioLocationQueue;
}

/**
 Returns shared instance of CurioLocationManager object
 
 @return CSSettings shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 
 Sends current location
 
 */
- (void) sendLocation;

@end

//
//  CurioNetwork.h
//  CurioSDK
//
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CurioReachabilityEx;



@interface CurioNetwork : NSObject

/**
    Stores whether network connection is online or not
 */
@property BOOL isOnline;

/**
    Stores whether network connection WAS online or not
 */
@property BOOL previouslyOnline;

/**
    Reachability info holder object
 */
@property CurioReachabilityEx *reachability;

/**
 Returns shared instance of CurioNetwork
 
 @return CurioNetwork shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
    Returns Carrier Name from CoreTelephony framework
 
    @return Carrier name 
 */
- (NSString *) carrierName;

/**
    Returns Carrier country code
 */
- (NSString *) carrierCountryCode;

/**
    Returns current connection type as string
 */
- (NSString *) connType;
@end

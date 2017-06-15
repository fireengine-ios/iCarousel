//
//  CurioNetwork.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

#if !TARGET_OS_TV
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif


/**
    
    Handles network status changes and notifies whenever it changes
    and stores current status in isOnline variable.
 
 */
@implementation CurioNetwork

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}



- (id) init {
    if ((self = [super init])) {
        
        _reachability = [CurioReachabilityEx reachabilityWithHostname:CS_OPT_NETWORK_CHECK_HOST];
        
        __unsafe_unretained CurioNetwork *slf = self;
        
        _reachability.reachableBlock = ^(CurioReachabilityEx *reach) {
            
                slf.isOnline = reach.isReachable;
            
                //if (!slf.previouslyOnline && slf.isOnline) {
                    // Moved from offline to online
                    [CurioSDK shared].retryCount = 0;
                    [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_NEW_ACTION object:nil];
                    
                //}
            
                slf.previouslyOnline = slf.isOnline;
            
        };
        
        __weak CurioReachabilityEx *weakReachability = _reachability;
        
        _reachability.unreachableBlock = ^(CurioReachabilityEx *reach) {
            
            // Sometimes unreachable block runs even if we have a connection
            // that's why we are passing reach variable to reachable block
            weakReachability.reachableBlock(reach);
        };
        
        
        [_reachability startNotifier];
        
        _previouslyOnline = _reachability.isReachable;
        _isOnline = _reachability.isReachable;
    }

    return self;
}

- (NSString *) connType {
    
    return _reachability.isReachableViaWiFi ? CURNetworkTypeWifi : _reachability.isReachableViaWWAN ? CURNetworkTypeMobile : CURNetworkTypeOffline;
    
}

- (NSString *) carrierCountryCode {
    
#if !TARGET_OS_TV
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    return carrier.mobileCountryCode != nil ? [carrier.mobileCountryCode uppercaseString] : CURNetworkCarrierUnknown;
#endif
    
    return CURNetworkCarrierUnknown;
    
}

- (NSString *) carrierName {
    
#if !TARGET_OS_TV
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    return carrier.carrierName != nil ? [carrier.carrierName uppercaseString] : CURNetworkCarrierUnknown;
#endif
    
    return CURNetworkCarrierUnknown;
    
    
}
@end

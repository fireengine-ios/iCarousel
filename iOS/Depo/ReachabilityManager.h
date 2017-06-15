//
//  ReachabilityManager.h
//  Depo
//
//  Created by Mahir on 27/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ReachabilityManager : NSObject

@property (nonatomic, strong) Reachability *reachability;

+ (ReachabilityManager *) currentManager;
+ (BOOL) isReachable;
+ (BOOL) isReachableViaWWAN;
+ (BOOL) isReachableViaWiFi;

@end

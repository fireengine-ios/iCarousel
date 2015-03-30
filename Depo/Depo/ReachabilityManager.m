//
//  ReachabilityManager.m
//  Depo
//
//  Created by Mahir on 27/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ReachabilityManager.h"
#import "Reachability.h"

@implementation ReachabilityManager

- (id)init {
    if (self = [super init]) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
    }
    return self;
}

+ (ReachabilityManager *) currentManager {
    static ReachabilityManager *_currentManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentManager = [[self alloc] init];
    });
    
    return _currentManager;
}

- (void)dealloc {
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

+ (BOOL)isReachable {
    return [[[ReachabilityManager currentManager] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[[ReachabilityManager currentManager] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[[ReachabilityManager currentManager] reachability] isReachableViaWiFi];
}

@end

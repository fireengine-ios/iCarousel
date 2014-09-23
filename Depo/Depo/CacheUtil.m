//
//  CacheUtil.m
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "CacheUtil.h"
#import "AppConstants.h"

@implementation CacheUtil

+ (NSString *) readCachedMsisdn {
    return [[NSUserDefaults standardUserDefaults] objectForKey:MSISDN_STORE_KEY];
}

+ (NSString *) readCachedPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PASS_STORE_KEY];
}

+ (void) writeCachedMsisdn:(NSString *) newMsisdn {
    [[NSUserDefaults standardUserDefaults] setObject:newMsisdn forKey:MSISDN_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeCachedPassword:(NSString *) newPass {
    [[NSUserDefaults standardUserDefaults] setObject:newPass forKey:PASS_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetCachedMsisdn {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:MSISDN_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetCachedPassword {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASS_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

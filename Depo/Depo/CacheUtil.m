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

+ (BOOL) showConfirmDeletePageFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_DELETE_HIDDEN_KEY];
}

+ (void) setConfirmDeletePageFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CONFIRM_DELETE_HIDDEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) cacheSearchHistoryItem:(SearchHistory *) historyItem {
    NSArray *result = [CacheUtil readSearchHistoryItems];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:result] forKey:SEARCH_HISTORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) readSearchHistoryItems {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_HISTORY_KEY];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    //TODO sort
    return result;
}

@end

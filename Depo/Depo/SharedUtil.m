//
//  SharedUtil.m
//  Depo
//
//  Created by Mahir on 18/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "SharedUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "MetaFileSummary.h"

#ifdef PLATFORM_STORE
#define SHARED_GROUP_NAME @"group.com.turkcell.akillidepo"
#elif defined PLATFORM_ICT
#define SHARED_GROUP_NAME @"group.com.turkcell.akillideponew.ent"
#else
#define SHARED_GROUP_NAME @"group.com.rdc.lifebox2"
#endif
#define SHARED_TOKEN_KEY @"SHARED_TOKEN_KEY"
#define SHARED_REMEMBER_ME_TOKEN_KEY @"SHARED_REMEMBER_ME_TOKEN_KEY"
#define SHARED_BASE_URL @"SHARED_BASE_URL"
#define SHARED_BASE_URL_CONSTANT @"SHARED_BASE_URL_CONSTANT"
#define SYNCED_REMOTE_FILES_SUMMARY_KEY @"SYNCED_REMOTE_FILES_SUMMARY_KEY_%@"

@implementation SharedUtil

+ (void) writeSharedToken:(NSString *) token {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:token forKey:SHARED_TOKEN_KEY];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedToken {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    NSString* token = [sharedDefaults objectForKey:SHARED_TOKEN_KEY];
    return token;
}

+ (void) writeSharedRememberMeToken:(NSString *) token {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:token forKey:SHARED_REMEMBER_ME_TOKEN_KEY];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedRememberMeToken {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    NSString* token = [sharedDefaults objectForKey:SHARED_REMEMBER_ME_TOKEN_KEY];
    return token;
}

+ (void) writeSharedBaseUrl:(NSString *) url {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:url forKey:SHARED_BASE_URL];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedBaseUrl {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    return [sharedDefaults objectForKey:SHARED_BASE_URL];
}

+ (void) writeSharedBaseUrlConstant:(NSString *) url {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:url forKey:SHARED_BASE_URL_CONSTANT];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedBaseUrlConstant {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    return [sharedDefaults objectForKey:SHARED_BASE_URL_CONSTANT];
}

+ (void) cacheSyncFileSummary:(MetaFileSummary *) summary {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        NSArray *result = [SharedUtil readSyncFileSummaries];
        if(![result containsObject:summary]) {
            NSArray *updatedArray = [result arrayByAddingObject:summary];
            NSString *baseUrlConstant = [SharedUtil readSharedBaseUrlConstant] != nil ? [SharedUtil readSharedBaseUrlConstant] : @"";
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
            [sharedDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, baseUrlConstant]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

+ (void) cacheSyncFileSummaries:(NSMutableArray *) newArray {
    NSArray *result = [SharedUtil readSyncFileSummaries];
    NSArray *updatedArray = [result arrayByAddingObjectsFromArray:newArray];
    NSString *baseUrlConstant = [SharedUtil readSharedBaseUrlConstant] != nil ? [SharedUtil readSharedBaseUrlConstant] : @"";
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, baseUrlConstant]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) readSyncFileSummaries {
    NSArray *result = [[NSArray alloc] init];
    NSString *baseUrlConstant = [SharedUtil readSharedBaseUrlConstant] != nil ? [SharedUtil readSharedBaseUrlConstant] : @"";
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    NSData *arrData = [sharedDefaults objectForKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, baseUrlConstant]];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (NSString *) md5String:(NSData *) data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], [data length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

+ (NSString *) md5StringOfString:(NSString *) rawVal {
    const char *cstr = [rawVal UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

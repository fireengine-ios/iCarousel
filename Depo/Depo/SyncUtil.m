//
//  SyncUtil.m
//  Depo
//
//  Created by Mahir on 25.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SyncUtil.h"
#import "AppConstants.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SyncUtil

+ (NSDate *) readLastSyncDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYNC_DATE];
}

+ (void) writeLastSyncDate:(NSDate *) syncDate {
    [[NSUserDefaults standardUserDefaults] setObject:syncDate forKey:LAST_SYNC_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) updateLastSyncDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_SYNC_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) cacheSyncReference:(SyncReference *) ref {
    NSArray *result = [SyncUtil readSyncReferences];
    BOOL shouldAdd = YES;
    for(SyncReference *row in result) {
        if([row.uuid isEqualToString:ref.uuid]) {
            shouldAdd = NO;
            break;
        }
    }
    if(shouldAdd) {
        NSArray *updatedArray = [result arrayByAddingObject:ref];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:SYNC_REF_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *) readSyncReferences {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SYNC_REF_KEY];
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

+ (NSString *) md5StringFromPath:(NSString *) path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5";
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength:1024];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

+ (void) cacheSyncHashLocally:(NSString *) hash {
    NSArray *result = [SyncUtil readSyncHashLocally];
    if(![result containsObject:hash]) {
        NSArray *updatedArray = [result arrayByAddingObject:hash];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:SYNCED_LOCAL_HASHES_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *) readSyncHashLocally {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SYNCED_LOCAL_HASHES_KEY];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (void) cacheSyncHashRemotely:(NSString *) hash {
    NSArray *result = [SyncUtil readSyncHashRemotely];
    if(![result containsObject:hash]) {
        NSArray *updatedArray = [result arrayByAddingObject:hash];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:SYNCED_REMOTE_HASHES_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *) readSyncHashRemotely {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SYNCED_REMOTE_HASHES_KEY];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

@end

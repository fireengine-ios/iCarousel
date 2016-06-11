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
#import "ContactSyncSDK.h"
#import "AppDelegate.h"
#import "AppSession.h"

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

+ (NSDate *) readLastContactSyncDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CONTACT_SYNC_DATE];
}

+ (void) updateLastContactSyncDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_CONTACT_SYNC_DATE];
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_LOCAL_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void) removeLocalHash:(NSString *) hash {
    if(hash == nil)
        return;
    NSArray *result = [SyncUtil readSyncHashLocally];
    if([result containsObject:hash]) {
        NSMutableArray *updatedArray = [result mutableCopy];
        [updatedArray removeObject:hash];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_LOCAL_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *) readSyncHashLocally {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:SYNCED_LOCAL_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
//    NSLog(@"LOCAL HASH KEY:%@", [NSString stringWithFormat:SYNCED_LOCAL_HASHES_KEY, [SyncUtil readBaseUrlConstant]]);
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (BOOL) localHashListContainsHash:(NSString *) hash {
    return [[SyncUtil readSyncHashLocally] containsObject:hash];
}

+ (void) cacheSyncHashRemotely:(NSString *) hash {
    NSArray *result = [SyncUtil readSyncHashRemotely];
    if(![result containsObject:hash]) {
        NSArray *updatedArray = [result arrayByAddingObject:hash];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void) cacheSyncHashesRemotely:(NSMutableArray *) newArray {
    NSArray *result = [SyncUtil readSyncHashRemotely];
    NSArray *updatedArray = [result arrayByAddingObjectsFromArray:newArray];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) readSyncHashRemotely {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:SYNCED_REMOTE_HASHES_KEY, [SyncUtil readBaseUrlConstant]]];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (void) cacheSyncFileSummary:(MetaFileSummary *) summary {
    NSArray *result = [SyncUtil readSyncFileSummaries];
    if(![result containsObject:summary]) {
        NSArray *updatedArray = [result arrayByAddingObject:summary];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, [SyncUtil readBaseUrlConstant]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void) cacheSyncFileSummaries:(NSMutableArray *) newArray {
    NSArray *result = [SyncUtil readSyncFileSummaries];
    NSArray *updatedArray = [result arrayByAddingObjectsFromArray:newArray];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) readSyncFileSummaries {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:SYNCED_REMOTE_FILES_SUMMARY_KEY, [SyncUtil readBaseUrlConstant]]];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (void) writeFirstTimeSyncFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:FIRST_SYNC_DONE_FLAG_KEY, [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readFirstTimeSyncFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:FIRST_SYNC_DONE_FLAG_KEY, [SyncUtil readBaseUrlConstant]]];
}

+ (void) writeFirstTimeSyncFinishedFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:FIRST_SYNC_FINALIZED_FLAG_KEY, [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readFirstTimeSyncFinishedFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:FIRST_SYNC_FINALIZED_FLAG_KEY, [SyncUtil readBaseUrlConstant]]];
}

+ (void) lockAutoSyncBlockInProgress {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) unlockAutoSyncBlockInProgress {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readAutoSyncBlockInProgress {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY];
}

+ (void) increaseBadgeCount {
    int newBadgeCount = [SyncUtil readBadgeCount] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:newBadgeCount forKey:UPLOAD_FILE_BADGE_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeCount];
}

+ (void) resetBadgeCount {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:UPLOAD_FILE_BADGE_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) readBadgeCount {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:UPLOAD_FILE_BADGE_COUNT_KEY];
}

/*
+ (void) startContactAutoSync {
    [SyncSettings shared].token = APPDELEGATE.session.authToken;
    [SyncSettings shared].url = CONTACT_SYNC_SERVER_URL;
    [SyncSettings shared].periodicSync = YES;
    [ContactSyncSDK doSync];
}

+ (void) stopContactAutoSync {
    if ([ContactSyncSDK automated]){
        [ContactSyncSDK cancel];
    }
}
 */

+ (void) writeLastContactSyncResult:(ContactSyncResult *) syncResult {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:syncResult] forKey:LAST_CONTACT_SYNC_RESULT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ContactSyncResult *) readLastContactSyncResult {
    ContactSyncResult *result = nil;
    NSData *resultData = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CONTACT_SYNC_RESULT];
    if (resultData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
    }
    return result;
}

+ (void) increaseAutoSyncIndex {
    int newAutoSyncIndex = [SyncUtil readAutoSyncIndex] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:newAutoSyncIndex forKey:[NSString stringWithFormat:AUTO_SYNC_INDEX_KEY, [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) readAutoSyncIndex {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:AUTO_SYNC_INDEX_KEY, [SyncUtil readBaseUrlConstant]]];
}

+ (NSMutableDictionary *) readOngoingTasks {
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:ONGOING_TASKS_KEY];
    if(!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    return dict;
}

+ (void) resetOngoingTasks {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ONGOING_TASKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) addToOngoingTasksWithFilename:(NSString *) filename andTaskUrl:(NSString *) taskUrl {
    NSMutableDictionary *currentDict = [[NSUserDefaults standardUserDefaults] objectForKey:ONGOING_TASKS_KEY];
    if(currentDict == nil) {
        currentDict = [NSMutableDictionary dictionaryWithObject:taskUrl forKey:filename];
        [[NSUserDefaults standardUserDefaults] setObject:currentDict forKey:ONGOING_TASKS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        if([currentDict objectForKey:filename] == nil) {
            NSMutableDictionary *mutableDict = [currentDict mutableCopy];
            [mutableDict setObject:taskUrl forKey:filename];
            [[NSUserDefaults standardUserDefaults] setObject:mutableDict forKey:ONGOING_TASKS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (void) writeBaseUrlConstant:(NSString *) baseUrlConstant {
    [[NSUserDefaults standardUserDefaults] setValue:baseUrlConstant forKey:PERSISTENT_BASE_URL_CONSTANT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetBaseUrlConstant {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PERSISTENT_BASE_URL_CONSTANT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readBaseUrlConstant {
    return [[NSUserDefaults standardUserDefaults] valueForKey:PERSISTENT_BASE_URL_CONSTANT_KEY];
}

+ (void) writeBaseUrl:(NSString *) baseUrl {
    [[NSUserDefaults standardUserDefaults] setValue:baseUrl forKey:PERSISTENT_BASE_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetBaseUrl {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PERSISTENT_BASE_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readBaseUrl {
    return [[NSUserDefaults standardUserDefaults] valueForKey:PERSISTENT_BASE_URL_KEY];
}

+ (void) writeLastLocUpdateTime:(NSDate *) date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:LAST_LOC_UPDATE_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetLastLocUpdateTime {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:LAST_LOC_UPDATE_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *) readLastLocUpdateTime {
    return [[ NSUserDefaults standardUserDefaults] objectForKey:LAST_LOC_UPDATE_TIME_KEY];
}

+ (void) write413Lock:(BOOL) newVal {
    [[NSUserDefaults standardUserDefaults] setBool:newVal forKey:QUOTA_413_LOCK_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) read413Lock {
    return [[ NSUserDefaults standardUserDefaults] boolForKey:QUOTA_413_LOCK_KEY];
}

+ (void) writeLast413CheckDate:(NSDate *) date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:QUOTA_413_LAST_CHECK_DATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *) readLast413CheckDate {
    return [[ NSUserDefaults standardUserDefaults] objectForKey:QUOTA_413_LAST_CHECK_DATE_KEY];
}

+ (BOOL) isLast413CheckDateOneDayOld {
    NSDate *lastDate = [SyncUtil readLast413CheckDate];
    if(lastDate) {
        NSDate *now = [NSDate date];
        NSTimeInterval diffBetweenDates = [now timeIntervalSinceDate:lastDate];
        return diffBetweenDates >= 3600;
    }
    return YES;
}

@end

//
//  SyncUtil.h
//  Depo
//
//  Created by Mahir on 25.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncReference.h"
#import "ContactSyncResult.h"
#import "MetaFileSummary.h"

@interface SyncUtil : NSObject

+ (NSDate *) readLastSyncDate;
+ (NSDate *) readLastContactSyncDate;
+ (void) writeLastSyncDate:(NSDate *) syncDate;
+ (void) updateLastSyncDate;
+ (void) updateLastContactSyncDate;
+ (void) cacheSyncReference:(SyncReference *) ref;
+ (NSArray *) readSyncReferences;
+ (NSString *) md5StringOfString:(NSString *) rawVal;
+ (NSString *) md5String:(NSData *) data;
+ (NSString *) md5StringFromPath:(NSString *) path;

+ (void) cacheSyncHashLocally:(NSString *) hash;
+ (NSArray *) readSyncHashLocally;
+ (void) cacheSyncHashRemotely:(NSString *) hash;
+ (void) cacheSyncHashesRemotely:(NSMutableArray *) newArray;
+ (NSArray *) readSyncHashRemotely;
+ (void) writeFirstTimeSyncFlag;
+ (BOOL) readFirstTimeSyncFlag;
+ (void) writeFirstTimeSyncFinishedFlag;
+ (BOOL) readFirstTimeSyncFinishedFlag;
+ (void) increaseBadgeCount;
+ (void) resetBadgeCount;
+ (int) readBadgeCount;

+ (void) cacheSyncFileSummary:(MetaFileSummary *) summary;
+ (void) cacheSyncFileSummaries:(NSMutableArray *) newArray;
+ (NSArray *) readSyncFileSummaries;

+ (void) writeLastContactSyncResult:(ContactSyncResult *) syncResult;
+ (ContactSyncResult *) readLastContactSyncResult;

+ (void) increaseAutoSyncIndex;
+ (int) readAutoSyncIndex;

+ (void) lockAutoSyncBlockInProgress;
+ (void) unlockAutoSyncBlockInProgress;
+ (BOOL) readAutoSyncBlockInProgress;

+ (NSMutableDictionary *) readOngoingTasks;
+ (void) resetOngoingTasks;
+ (void) addToOngoingTasksWithFilename:(NSString *) filename andTaskUrl:(NSString *) taskUrl;

@end

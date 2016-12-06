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

+ (NSString *) md5StringOfFileLocalIdentifier:(NSString *)identifier;
+ (NSString *) md5StringOfString:(NSString *) rawVal;
+ (NSString *) md5String:(NSData *) data;
+ (NSString *) md5StringFromPath:(NSString *) path;

+ (void) cacheSyncHashLocally:(NSString *) hash;
+ (void) removeLocalHash:(NSString *) hash;
+ (NSArray *) readSyncHashLocally;
+ (BOOL) localHashListContainsHash:(NSString *) hash;
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

+ (void) writeBaseUrlConstant:(NSString *) baseUrlConstant;
+ (void) resetBaseUrlConstant;
+ (NSString *) readBaseUrlConstant;

+ (void) writeBaseUrl:(NSString *) baseUrlConstant;
+ (void) resetBaseUrl;
+ (NSString *) readBaseUrl;

+ (void) writeLastLocUpdateTime:(NSDate *) date;
+ (void) resetLastLocUpdateTime;
+ (NSDate *) readLastLocUpdateTime;

+ (void) write413Lock:(BOOL) newVal;
+ (BOOL) read413Lock;

+ (void) writeLast413CheckDate:(NSDate *) date;
+ (NSDate *) readLast413CheckDate;
+ (BOOL) isLast413CheckDateOneDayOld;

+ (void) writeOneTimeSyncFlag;
+ (BOOL) readOneTimeSyncFlag;

+ (void) writeBaseUrlConstantForLocPopup:(NSString *) baseUrlConstantForLocPopup;
+ (NSString *) readBaseUrlConstantForLocPopup;


+(NSArray *)loadDownloadedFilesForAlbum:(NSString *)albumName;
+(void)createAlbumToSync:(NSString *)albumName;
+(void)removeAlbumFromSync:(NSString *)albumName;
+(void)updateLoadedFiles:(NSArray *)files inAlbum:(NSString *)albumName;

@end

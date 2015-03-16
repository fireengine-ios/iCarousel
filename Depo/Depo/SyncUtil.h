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

@interface SyncUtil : NSObject

+ (NSDate *) readLastSyncDate;
+ (NSDate *) readLastContactSyncDate;
+ (void) writeLastSyncDate:(NSDate *) syncDate;
+ (void) updateLastSyncDate;
+ (void) updateLastContactSyncDate;
+ (void) cacheSyncReference:(SyncReference *) ref;
+ (NSArray *) readSyncReferences;
+ (NSString *) md5String:(NSData *) data;
+ (NSString *) md5StringFromPath:(NSString *) path;

+ (void) cacheSyncHashLocally:(NSString *) hash;
+ (NSArray *) readSyncHashLocally;
+ (void) cacheSyncHashRemotely:(NSString *) hash;
+ (NSArray *) readSyncHashRemotely;
+ (void) writeFirstTimeSyncFlag;
+ (BOOL) readFirstTimeSyncFlag;
+ (void) increaseBadgeCount;
+ (void) resetBadgeCount;
+ (int) readBadgeCount;

+ (void) writeLastContactSyncResult:(ContactSyncResult *) syncResult;
+ (ContactSyncResult *) readLastContactSyncResult;

@end

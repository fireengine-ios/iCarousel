//
//  SyncDB.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SyncConstants.h"

#define TABLE_CONTACT_SYNC @"CONTACT_SYNC"
#define COLUMN_MSISDN @"MSISDN"
#define COLUMN_LOCAL_ID @"LOCAL_ID"
#define COLUMN_REMOTE_ID @"REMOTE_ID"
#define COLUMN_LOCAL_UPDATE_DATE @"LOCAL_UPDATE_DATE"
#define COLUMN_REMOTE_UPDATE_DATE @"REMOTE_UPDATE_DATE"
#define COLUMN_CHECKSUM @"CHECKSUM"

#define SYNC_DB_FILE_NAME @"contact_sync_sdk_200120.db"

typedef void(^SyncDBMutexRun)(sqlite3 *db);

@interface SyncDB : NSObject

@property BOOL isDbOpen;

/**
 Returns shared instance of SyncDB
 
 @return SyncDB shared instance
 */
+ (SYNC_INSTANCETYPE) shared;

/**
    Executes block in thread-safe mode with Sqlite3 db
 */
- (void) invokeBlockSafe:(SyncDBMutexRun)syncDBMutexRunBlock;

/**
    Executes sql with thread-safe mode
 
    @return If sql executed successfully with no error
 */
- (BOOL) executeSafe:(NSString *)sql;

/**
    Creates default table to save actions
 */
- (void) createDefaultTable;
@end

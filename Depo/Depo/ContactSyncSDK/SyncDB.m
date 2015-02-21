//
//  SyncDB.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#include <pthread.h>
#import "SyncDB.h"
#import "SyncSettings.h"

/**
    Core Database functionality object to maintain execution
    of SQL statements.
 */
@implementation SyncDB

static sqlite3 *db;
static pthread_mutex_t mutex;
static pthread_mutex_t mutexInvoke;

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id) init {
    if ((self = [super init])) {
        
        pthread_mutex_init(&mutex, NULL);
        pthread_mutex_init(&mutexInvoke, NULL);
        
        
        [self openDb];
    }
    return self;
}

- (void) invokeBlockSafe:(SyncDBMutexRun)syncDBMutexRunBlock {
    if (!_isDbOpen)
        return;
    
    pthread_mutex_lock(&mutexInvoke);

    syncDBMutexRunBlock(db);
    
    pthread_mutex_unlock(&mutexInvoke);

}

- (BOOL) executeSafe:(NSString *)_sql {
    
    if (!_isDbOpen)
        return FALSE;
    
    __block BOOL allOk = TRUE;
    
    __block NSString *sql = [_sql copy];
    
    [self invokeBlockSafe:^(sqlite3 *db) {
        char *errmsg;
        int ret;
        
        ret = sqlite3_exec(db, [sql UTF8String], 0, 0, &errmsg);
        
        if (ret != SQLITE_OK)
        {
            allOk = FALSE;
            SYNC_Log(@"Error in statement: %@ [%@].\n",  sql, [NSString stringWithCString:errmsg encoding:NSUTF8StringEncoding]);
        }
        
    }];
    
    return allOk;
    
}

- (void) createDefaultTable {
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ ( %@ STRING, \
                     %@ INTEGER, \
                     %@ INTEGER, \
                     %@ INTEGER, \
                     %@ INTEGER);", TABLE_CONTACT_SYNC, COLUMN_MSISDN, COLUMN_LOCAL_ID, COLUMN_REMOTE_ID, COLUMN_LOCAL_UPDATE_DATE, COLUMN_REMOTE_UPDATE_DATE] ;
    
    [self executeSafe:sql];
    
    [self executeSafe:[NSString stringWithFormat:@"CREATE INDEX local_id_idx ON %@ (%@);",TABLE_CONTACT_SYNC, COLUMN_LOCAL_ID]];
    [self executeSafe:[NSString stringWithFormat:@"CREATE INDEX remote_id_idx ON %@ (%@);",TABLE_CONTACT_SYNC, COLUMN_REMOTE_ID]];
    
}

- (BOOL) openDb {
    
    if (_isDbOpen)
        return TRUE;
    
    pthread_mutex_lock(&mutex);
    
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath =  [pathList objectAtIndex:0];
    NSString *dbPath = [[NSString alloc] initWithString:[documentDirectoryPath stringByAppendingPathComponent:SYNC_DB_FILE_NAME]];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    
    SYNC_Log(@"Db path: %@",dbPath);
    
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK)
    {
        
        _isDbOpen = TRUE;
        
        if (!exists)
        {
            [self createDefaultTable];
        }
    } else {
        SYNC_Log(@"Could not open database");
    }
    
    
    pthread_mutex_unlock(&mutex);
    
    
    return _isDbOpen;
    
}


@end

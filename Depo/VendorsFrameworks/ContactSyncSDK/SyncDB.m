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
                     %@ INTEGER, \
                     %@ STRING);", TABLE_CONTACT_SYNC, COLUMN_MSISDN, COLUMN_LOCAL_ID, COLUMN_REMOTE_ID, COLUMN_LOCAL_UPDATE_DATE, COLUMN_REMOTE_UPDATE_DATE, COLUMN_CHECKSUM] ;
    
    [self executeSafe:sql];
    
    [self executeSafe:[NSString stringWithFormat:@"CREATE INDEX local_id_idx ON %@ (%@);",TABLE_CONTACT_SYNC, COLUMN_LOCAL_ID]];
    [self executeSafe:[NSString stringWithFormat:@"CREATE INDEX remote_id_idx ON %@ (%@);",TABLE_CONTACT_SYNC, COLUMN_REMOTE_ID]];
    
}

- (BOOL) openDb {
    
    if (_isDbOpen)
        return TRUE;
    
    pthread_mutex_lock(&mutex);

    NSArray *cachePathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath =  [cachePathList objectAtIndex:0];
    NSString *oldDbPath = [[NSString alloc] initWithString:[documentDirectoryPath stringByAppendingPathComponent:SYNC_DB_FILE_NAME]];
    
    BOOL oldDbExists = [[NSFileManager defaultManager] fileExistsAtPath:oldDbPath];
    
    NSArray *supportPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *supportDirectoryPath = [supportPathList objectAtIndex:0];
    NSString *newDbPath = [[NSString alloc] initWithString:[supportDirectoryPath stringByAppendingPathComponent:SYNC_DB_FILE_NAME]];
    
    BOOL newDbExists = [[NSFileManager defaultManager] fileExistsAtPath:newDbPath];
    
    if(oldDbExists){
        SYNC_Log(@"Old database was found: %@",oldDbPath);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if (newDbExists == NO) {
            @try {
                [fileManager copyItemAtPath:oldDbPath toPath:newDbPath error:&error];
                if(error){
                    SYNC_Log(@"DB migration error: %@",error);
                    newDbPath = oldDbPath;
                }else{
                    [fileManager removeItemAtPath:oldDbPath error:&error];
                    if(error){
                        SYNC_Log(@"There was an error deleting the old database: %@", error);
                    }
                    SYNC_Log(@"Migration completed: %@", newDbPath);
                }
            } @catch (NSException *exception) {
                newDbPath = oldDbPath;
                SYNC_Log(@"There was an unknown error while migrating.: %@", exception);
            } @finally {
                newDbExists = YES;
            }
            
        }
    }
    
    SYNC_Log(@"Db path: %@",newDbPath);

    if (sqlite3_open([newDbPath UTF8String], &db) == SQLITE_OK)
    {
        
        _isDbOpen = TRUE;
        
        if (!newDbExists)
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

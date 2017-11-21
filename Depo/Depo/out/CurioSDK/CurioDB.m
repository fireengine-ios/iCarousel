//
//  CurioDB.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 17/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"


#include <pthread.h>


/**
 
    Core Database functionality object to maintain execution
    of SQL statements.
 
 */
@implementation CurioDB

static sqlite3 *db;
static pthread_mutex_t mutex;
static pthread_mutex_t mutexInvoke;


+ (CS_INSTANCETYPE) shared {
    
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

- (void) invokeBlockSafe:(CurioDBMutexRun)curioDBMutexRunBlock {
    
    
    
    if (!_isDbOpen)
        return;
    
//    sqlite3_mutex_enter(sqlite3_db_mutex(db));
    pthread_mutex_lock(&mutexInvoke);

    
    curioDBMutexRunBlock(db);
    
//    sqlite3_mutex_leave(sqlite3_db_mutex(db));
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
            CS_Log_Debug(@"Error in statement: %@ [%@].\n",  sql, [NSString stringWithCString:errmsg encoding:NSUTF8StringEncoding]);
        }
        
    }];
    
    return allOk;
    
}

- (void) createNotificationHistoryTableIfNotExists {
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS NOTIFICATIONS (  NID INTEGER, \
    DEVICETOKEN TEXT, \
    PUSHID  TEXT \
    );";
    
    [self executeSafe:sql];
    
}

- (void) createLocationHistoryTableIfNotExists {
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS LOCATIONS (  LID INTEGER, \
    LATITUDE TEXT, \
    LONGITUDE  TEXT \
    );";
    
    [self executeSafe:sql];
    
}

- (void) createDefaultTableIfNotExists {
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS ACTIONS ( AID INTEGER, \
    TYPE INTEGER, \
    STAMP INTEGER, \
    TITLE TEXT, \
    PATH  TEXT, \
    HITCODE  TEXT, \
    EVENTKEY  TEXT, \
    EVENTVALUE TEXT, \
    ONLINE INTEGER, \
    PROPERTIES TEXT);";
    
    [self executeSafe:sql];
    
}




- (BOOL) openDb {
    
    if (_isDbOpen)
        return TRUE;
    
    pthread_mutex_lock(&mutex);
    
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath =  [pathList objectAtIndex:0];
    NSString *dbPath = [[NSString alloc] initWithString:[documentDirectoryPath stringByAppendingPathComponent:CS_OPT_DB_FILE_NAME]];
    
    //BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    
    CS_Log_Debug(@"Db path: %@",dbPath);
    
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK)
    {
        
        _isDbOpen = TRUE;

        [self createDefaultTableIfNotExists];
            
        [self createNotificationHistoryTableIfNotExists];
            
        [self createLocationHistoryTableIfNotExists];
        
    } else {
        CS_Log_Error(@"Could not open database");
    }
    
    
    pthread_mutex_unlock(&mutex);
    
    
    return _isDbOpen;
    
}


@end

//
//  SyncDBUtils.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncDBUtils.h"
#import "SyncDB.h"


@implementation SyncDBUtils

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}
- (BOOL) save:(SyncRecord *) record
{
    NSString *sql = nil;
    NSArray *result = [self fetch:[NSString stringWithFormat:@"%@=%lld AND %@=%lld",COLUMN_LOCAL_ID,[record.localId longLongValue],COLUMN_REMOTE_ID,[record.remoteId longLongValue]]];
    BOOL isNew = NO;
    if (SYNC_ARRAY_IS_NULL_OR_EMPTY(result)){
        sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES('%@', %lld, %lld ,%lld,%lld)",
                     TABLE_CONTACT_SYNC,
                     [SyncSettings shared].msisdn,
                     [record.localId longLongValue],
                     [record.remoteId longLongValue],
                     [record.localUpdateDate longLongValue],
                     [record.remoteUpdateDate longLongValue]
                     ];
        isNew = YES;
    } else {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET %@=%lld, %@=%lld, %@=%lld WHERE %@ = '%@' AND %@ = %@",
               TABLE_CONTACT_SYNC,
               COLUMN_REMOTE_ID,
               [record.remoteId longLongValue],
               COLUMN_LOCAL_UPDATE_DATE,
               [record.localUpdateDate longLongValue],
               COLUMN_REMOTE_UPDATE_DATE,
               [record.remoteUpdateDate longLongValue],
               COLUMN_MSISDN,
               [SyncSettings shared].msisdn,
               COLUMN_LOCAL_ID,
               record.localId
               ];
    }
    
    BOOL ret = [[SyncDB shared] executeSafe:sql];
    return ret;
}

- (BOOL) isDirty:(Contact *) contact
{
    NSArray *result = [self fetch:[NSString stringWithFormat:@"%@=%lld",COLUMN_LOCAL_ID,[contact.objectId longLongValue]]];
    if ([result count]==0){
        return YES;
    }
    SyncRecord *rec = (SyncRecord*)result[0];
    contact.remoteId = rec.remoteId;
    SYNC_Log(@"%lld %@ , %lld %@", [rec.localUpdateDate longLongValue], [NSDate dateWithTimeIntervalSince1970:[rec.localUpdateDate longLongValue]/1000],
             [contact.localUpdateDate longLongValue], [NSDate dateWithTimeIntervalSince1970:[contact.localUpdateDate longLongValue]/1000]);
    if ([rec.localUpdateDate longLongValue]>=[contact.localUpdateDate longLongValue]){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) hasRemoteId:(NSNumber*)remoteContactId
{
    NSArray *records = [self fetch:[NSString stringWithFormat:@"%@=%lld",COLUMN_REMOTE_ID,[remoteContactId longLongValue]]];
    if (SYNC_IS_NULL(records) || [records count]==0){
        return NO;
    } else {
        return YES;
    }
}

- (NSArray *) fetch
{
    return [self fetch:nil];
}

- (NSArray *) fetch:(NSString*)where
{
    NSMutableArray *ret = [NSMutableArray new];
    
    [[SyncDB shared] invokeBlockSafe:^(sqlite3 *db) {
        
        const char *sql = where==nil ? [[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",TABLE_CONTACT_SYNC, COLUMN_MSISDN, [SyncSettings shared].msisdn] UTF8String] : [[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND (%@)",TABLE_CONTACT_SYNC, COLUMN_MSISDN, [SyncSettings shared].msisdn, where] UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                SyncRecord *rec = [SyncRecord new];
                rec.localId = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, 1)];
                rec.remoteId = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, 2)];
                rec.localUpdateDate = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, 3)];
                rec.remoteUpdateDate = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, 4)];
                
                [ret addObject:rec];
                
            }
        } else {
            SYNC_Log(@"Failed in statement: %s",sqlite3_errmsg(db));
        }
        
        sqlite3_reset(statement);
        
    }];
    
    return ret;
}

- (void) deleteRecord:(NSNumber*)localId
{
    NSString *sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE %@ = '%@' AND %@ = %@", TABLE_CONTACT_SYNC, COLUMN_MSISDN, [SyncSettings shared].msisdn, COLUMN_LOCAL_ID, [localId stringValue]];
    [[SyncDB shared] executeSafe:sql];
}
- (void) deleteRecords:(NSArray*)ids
{
    NSString *sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE %@ = '%@' AND %@ IN (%@)", TABLE_CONTACT_SYNC, COLUMN_MSISDN, [SyncSettings shared].msisdn, COLUMN_LOCAL_ID, [ids componentsJoinedByString:@","]];
    [[SyncDB shared] executeSafe:sql];
}

@end

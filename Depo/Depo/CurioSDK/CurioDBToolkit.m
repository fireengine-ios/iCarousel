//
//  CurioDBToolkit.m
//  CurioSDK
//
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"


@implementation CurioDBToolkit

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void) purgeActions {
    
    [[CurioDB shared] executeSafe:@"DELETE FROM ACTIONS"] ;
}

- (void) deleteRecords:(NSArray *) actions {
    
    for (CurioAction *action in actions) {
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM ACTIONS WHERE AID = '%@'",  action.aId ];
        
        
        [[CurioDB shared] executeSafe:sql];
    }
    
}

- (void) markAsOfflineRecords:(NSArray *) actions {
    
    for (CurioAction *action in actions) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE ACTIONS SET ONLINE = %d WHERE AID = '%@'", [CS_NSN_FALSE intValue], action.aId ];
        
        
        [[CurioDB shared] executeSafe:sql];
    }
    
}

- (BOOL) addNotification:(CurioNotification *) notification {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO NOTIFICATIONS  VALUES('%@', '%@' ,'%@')",
                     notification.nId,
                     notification.deviceToken,
                     notification.pushId == nil ? @"" : notification.pushId
                     ];
    
    CS_Log_Debug("Notification (%@)",[notification asDict]);
    
    BOOL ret = [[CurioDB shared] executeSafe:sql];
    
    return ret;
}

- (void) deleteNotifications:(NSArray *) notifications {
    
    for (CurioNotification *notification in notifications) {
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM NOTIFICATIONS WHERE NID = '%@'",  notification.nId ];
        
        
        [[CurioDB shared] executeSafe:sql];
    }
    
}

- (NSArray *) getNotifications {
    
    NSMutableArray *ret = [NSMutableArray new];
    
    [[CurioDB shared] invokeBlockSafe:^(sqlite3 *db) {
        
        
        const char *sql = [@"SELECT * FROM NOTIFICATIONS ORDER BY NID DESC" UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                CurioNotification *act = [[CurioNotification alloc] init:CS_AS_STRING(sqlite3_column_text(statement, 0))
                                                       deviceToken:CS_AS_STRING(sqlite3_column_text(statement, 1))
                                                               pushId:CS_AS_STRING(sqlite3_column_text(statement, 2))];
                
                
                
                [ret addObject:act];
                
            }
        } else {
            CS_Log_Debug(@"Failed in statement: %s",sqlite3_errmsg(db));
        }
        
        sqlite3_reset(statement);
        
    }];
    
    return ret;
    
}


- (BOOL) addAction:(CurioAction *) action {
    
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO ACTIONS  VALUES('%@', %i ,'%@','%@','%@','%@','%@','%@',%@,'%@')",
                     action.aId,
                     action.actionType,
                     [[CurioUtil shared] urlEncode:action.stamp],
                     [[CurioUtil shared] urlEncode:action.title],
                     [[CurioUtil shared] urlEncode:action.path],
                     [[CurioUtil shared] urlEncode:action.hitCode],
                     [[CurioUtil shared] urlEncode:action.eventKey],
                     [[CurioUtil shared] urlEncode:action.eventValue],
                     action.isOnline,
                     [[CurioUtil shared] toJson:action.properties enablePercentEncoding:TRUE]
                     ];
    
    CS_Log_Debug(@"Action (%@) => %@",CS_ACTION_TYPE_TO_STR(action.actionType),CS_RM_STR_NEWLINE(
                                                                                                 [[CurioActionToolkit shared] actionToOnlinePostParameters:action]));
    
    BOOL ret = [[CurioDB shared] executeSafe:sql];
    
    if (ret) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_NEW_ACTION object:nil];
    }
    
    return ret;
    
}


- (NSArray *) getActions:(int) limit {

    NSMutableArray *ret = [NSMutableArray new];
    
    [[CurioDB shared] invokeBlockSafe:^(sqlite3 *db) {
        
        
        const char *sql = [[NSString stringWithFormat:@"SELECT * FROM ACTIONS ORDER BY AID DESC LIMIT %i",limit] UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {

                CurioAction *act = [[CurioAction alloc] init:CS_AS_STRING(sqlite3_column_text(statement, 0))
                                                        type:sqlite3_column_int(statement, 1)
                                                       stamp:CS_LLD_AS_STRING(sqlite3_column_int64(statement, 2))
                                                       title:CS_AS_STRING(sqlite3_column_text(statement, 3))
                                                        path:CS_AS_STRING(sqlite3_column_text(statement, 4))
                                                     hitCode:CS_AS_STRING(sqlite3_column_text(statement, 5))
                                                    eventKey:CS_AS_STRING(sqlite3_column_text(statement, 6))
                                                  eventValue:CS_AS_STRING(sqlite3_column_text(statement, 7))];
                
                act.isOnline = [NSNumber numberWithInt:sqlite3_column_int(statement,8)];
                act.properties = [NSMutableDictionary dictionaryWithDictionary:
                                  [[CurioUtil shared] fromJson:CS_AS_STRING(sqlite3_column_text(statement, 9)) percentEncoded:TRUE]];
                
                              
                [ret addObject:act];
                
            }
        } else {
            CS_Log_Debug(@"Failed in statement: %s",sqlite3_errmsg(db));
        }
        
        sqlite3_reset(statement);
        
    }];
    
    return ret;
    
}


@end

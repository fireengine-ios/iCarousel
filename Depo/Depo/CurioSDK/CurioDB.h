//
//  CurioDB.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 17/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <sqlite3.h>


typedef void(^CurioDBMutexRun)(sqlite3 *db);

@interface CurioDB : NSObject

@property BOOL isDbOpen;

/**
 Returns shared instance of CurioDB
 
 @return CurioDB shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
    Executes block in thread-safe mode with Sqlite3 db
 */
- (void) invokeBlockSafe:(CurioDBMutexRun)curioDBMutexRunBlock;

/**
    Executes sql with thread-safe mode
 
    @return If sql executed successfully with no error
 */
- (BOOL) executeSafe:(NSString *)sql;

@end

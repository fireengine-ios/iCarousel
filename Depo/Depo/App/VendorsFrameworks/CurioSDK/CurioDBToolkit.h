//
//  CurioDBToolkit.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioAction.h"
#import "CurioPushData.h"
#import "CurioLocationData.h"
#import "CurioUtil.h"
#import <sqlite3.h>


@interface CurioDBToolkit : NSObject


/**
 Returns shared instance of CurioDB
 
 @return CurioDB shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
    Inserts CurioAction object to db
 
    @return True if action saved successfully
 */
- (BOOL) addAction:(CurioAction *) action;

/**
    Retrieves actions in NSArray object with maximum limit rows.
 
    @return Array of CurioAction objects with maximim limit rows
 */
- (NSArray *) getActions:(int) limit;

/**
    Purges all the actions from db
 */
- (void) purgeActions;


/**
    Marks action records (CurioAction) sent within actions array as offline records
 */
- (void) markAsOfflineRecords:(NSArray *) actions;

/**
    Deletes action records (CurioAction) sent within actions array
 */
- (void) deleteRecords:(NSArray *) actions;


- (void) deleteStoredPushData:(NSArray *) pushDataArray;

- (BOOL) addPushData:(CurioPushData *) pushData;

- (NSArray *) getStoredPushData;

- (void) deleteStoredLocationData:(NSArray *) locationDataArray;

- (BOOL) addLocationData:(CurioLocationData *) locationData;

- (NSArray *) getStoredLocationData;

@end

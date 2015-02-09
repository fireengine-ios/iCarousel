//
//  SyncDBUtils.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SyncConstants.h"
#import "SyncRecord.h"
#import "SyncSettings.h"
#import "Contact.h"

@interface SyncDBUtils : NSObject

/**
 Returns shared instance of SyncDB
 
 @return SyncDB shared instance
 */
+ (SYNC_INSTANCETYPE) shared;

- (BOOL) save:(SyncRecord *) record;

- (BOOL) isDirty:(Contact *) contact;

- (NSArray *) fetch;

- (NSArray *) fetch:(NSString*)where;

- (void) deleteRecord:(NSNumber*)localId;
- (void) deleteRecords:(NSArray*)ids;

- (BOOL) hasRemoteId:(NSNumber*)remoteContactId;



@end

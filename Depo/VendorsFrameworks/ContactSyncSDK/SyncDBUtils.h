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

typedef NS_ENUM(NSUInteger, SYNCContactStatus) {
    NEW_CONTACT,
    UPDATED_CONTACT,
    UNDEFINED_CONTACT,
};

@interface SyncDBUtils : NSObject

/**
 Returns shared instance of SyncDB
 
 @return SyncDB shared instance
 */
+ (SYNC_INSTANCETYPE) shared;

- (BOOL) save:(SyncRecord *) record;

- (BOOL) save:(SyncRecord *) record status:(SYNCContactStatus)status;

- (SyncRecord *) isRecorded:(Contact *) contact;

- (NSArray *) fetch;

- (NSArray *) fetch:(NSString*)where;

- (void)printRecords;

- (void) deleteRecord:(NSNumber*)localId;
- (void) deleteRecords:(NSArray *)ids;
- (void) deleteRecordsWithIDs:(NSArray*)ids where:(NSString *)where;

- (BOOL) hasRemoteId:(NSNumber*)remoteContactId;



@end

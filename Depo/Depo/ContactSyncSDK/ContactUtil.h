//
//  ContactUtil.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "ContactDevice.h"

@interface ContactUtil : NSObject

+ (SYNC_INSTANCETYPE) shared;
- (void)checkAddressbookAccess:(void(^)(BOOL))callback;
- (BOOL)deleteContact:(NSNumber*)objectId;
- (void)deleteContact:(NSNumber*)contactId devices:(NSArray*)devices;
- (void)save:(Contact*)contact;
- (Contact*)findDuplicate:(Contact*)contact;
- (NSMutableArray*)fetchContacts;
- (Contact*)findContactById:(NSNumber*)objectId;
- (NSNumber*)localUpdateDate:(NSNumber*)objectId;
- (void)fetchNumbers:(Contact*)contact;
- (void)fetchEmails:(Contact*)contact;

@end

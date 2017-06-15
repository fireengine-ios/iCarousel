//
//  ContactUtil.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "ContactDevice.h"

@interface ContactUtil : NSObject

+ (SYNC_INSTANCETYPE) shared;
- (void) reset;
+ (NSString*)clearMsisdn:(NSString*)input;

- (void)checkAddressbookAccess:(void(^)(BOOL))callback;
- (void)deleteContact:(NSNumber*)contactId devices:(NSArray*)devices;
- (void)save:(Contact*)contact;
- (NSMutableArray *)applyContacts;
- (NSMutableArray*)fetchContacts;
- (NSInteger)getContactCount;
- (Contact*)findContactById:(NSNumber*)objectId;
- (NSNumber*)localUpdateDate:(NSNumber*)objectId;
- (void)fetchNumbers:(Contact*)contact;
- (void)fetchEmails:(Contact*)contact;

- (void)printContacts;

@end

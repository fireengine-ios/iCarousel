//
//  ContactUtil.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "ContactDevice.h"
#import "ContactAddress.h"
#import "Utils.h"
#import "PartialInfo.h"
#import "SyncStatus.h"


@interface ContactUtil : NSObject

+ (SYNC_INSTANCETYPE) shared;
- (void) reset;
+ (NSString*)clearMsisdn:(NSString*)input;

- (void)checkAddressbookAccess:(void(^)(BOOL))callback;
- (void)deleteContactDevices:(NSNumber*)contactId devices:(NSArray*)devices;
- (void)deleteContactAddresses:(NSNumber*)contactId addresses:(NSArray*)addresses;
- (void)deleteContacts:(NSMutableArray*) contacts;
- (void)save:(Contact*)contact;
- (void)saveList:(NSMutableArray<Contact*>*)contact;
- (NSMutableArray *)applyContacts:(NSInteger)syncRound;
- (NSMutableArray*)fetchLocalContacts;
- (NSMutableArray*)fetchContactIds;
- (NSMutableArray*)fetchContacts;
- (NSMutableArray*)fetchContacts:(NSInteger)bulkCount offset:(NSInteger)offset;
- (NSDictionary*)getContactData:(NSArray*)ids;
- (NSInteger)getContactCount;
- (Contact*)findContactById:(NSNumber*)objectId;
- (NSNumber*)localUpdateDate:(NSNumber*)objectId;
- (void)fetchNumbers:(Contact*)contact;
- (void)fetchEmails:(Contact*)contact;
- (void)fetchAddresses:(Contact*)contact;
- (Contact*)mergeContacts:(NSMutableArray<Contact *>*)contacts masterContact:(Contact*)masterContact;
-(NSArray *)getContactIds:(NSArray*)list;
- (NSString*)getCards:(PartialInfo*)partialInfo;
- (void)printContacts;
-(void)releaseAddressBookRef;

@end

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
#import "CNContactUnified.h"

typedef NS_ENUM(NSUInteger, CNContactFetchType) {
    ALL,
    ONLY_LOCAL,
    ALL_LOCAL,
};

@interface ContactUtil : NSObject

+ (SYNC_INSTANCETYPE) shared;
- (void) reset;

- (void)checkAddressbookAccess:(void(^)(BOOL))callback;
- (void)deleteContacts:(NSMutableArray*) contacts;
- (void)saveList:(NSMutableArray<Contact*>*)contact;
- (NSMutableArray*)fetchLocalContacts;
- (NSMutableArray*)fetchContacts:(CNContactFetchType)fetchType;
- (NSMutableArray*)fetchContacts:(NSInteger)bulkCount offset:(NSInteger)offset fetchType:(CNContactFetchType)fetchType;
- (NSInteger)getContactCount;
- (Contact*)mergeContacts:(NSMutableArray<Contact *>*)contacts masterContact:(Contact*)masterContact;
-(NSArray *)getContactIds:(NSArray*)list;
- (NSString*)getCards:(PartialInfo*)partialInfo;
-(void)releaseCNStore;

@end

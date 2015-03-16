//
//  Contact.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import <AddressBook/ABRecord.h>
#import <AddressBook/ABPerson.h>

@interface Contact : NSObject

@property (strong) NSNumber *objectId;
@property (strong) NSNumber *remoteId;
@property (strong) NSNumber *remoteUpdateDate;
@property (strong) NSNumber *localUpdateDate;

@property (strong) NSString *firstName;
@property (strong) NSString *middleName;
@property (strong) NSString *lastName;

@property (strong) NSMutableArray *devices;

@property ABRecordRef recordRef;

- (instancetype)initWithRecordRef:(ABRecordRef)ref;
- (instancetype)initWithDictionary:(NSDictionary*)json;
- (NSDictionary*) toJSON;
- (void)copyContact:(Contact*)contact;
- (NSString*)displayName;
- (BOOL)isDeviceSizeEqual:(Contact*)other;
- (BOOL)preEqualCheck:(id)object;

@end

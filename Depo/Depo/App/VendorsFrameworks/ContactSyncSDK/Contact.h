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

@interface Contact : NSObject<NSCopying>

@property (strong) NSNumber *objectId;
@property (strong) NSNumber *remoteId;
@property (strong) NSNumber *remoteUpdateDate;
@property (strong) NSNumber *localUpdateDate;

@property (strong) NSString *firstName;
@property (strong) NSString *middleName;
@property (strong) NSString *lastName;
@property (strong) NSString *nickName;
@property (strong) NSString *displayName;

@property (strong) NSMutableArray *devices;

@property BOOL hasName;
@property BOOL hasPhoneNumber;

@property ABRecordRef recordRef;

- (instancetype)initWithRecordRef:(ABRecordRef)ref;
- (instancetype)initWithDictionary:(NSDictionary*)json;
- (NSDictionary*) toJSON:(BOOL)isNewContact;
- (NSString*) toStringValue;
- (NSString*) toMD5;
- (void)copyContact:(Contact*)contact;
- (NSString*)generateDisplayName;
- (BOOL)isDeviceSizeEqual:(Contact*)other;
- (BOOL)preEqualCheck:(id)object;

@end

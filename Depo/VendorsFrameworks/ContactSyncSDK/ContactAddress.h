//
//  ContactAddress.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 12.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import <Contacts/CNMutablePostalAddress.h>
#import <Contacts/CNLabeledValue.h>

typedef NS_ENUM(NSUInteger, SYNCAddressType) {
    CADDRESS_HOME,
    CADDRESS_WORK,
    CADDRESS_OTHER
};

@interface ContactAddress : NSObject<NSCopying>

@property (strong) NSNumber *remoteId;
@property (strong) NSString *street;
@property (strong) NSString *postalCode;
@property (strong) NSString *district;
@property (strong) NSString *city;
@property (strong) NSString *country;
@property (strong) NSString *contactIdentifier;
@property BOOL deleted;
@property SYNCAddressType type;

/**
 * Use this contructor to init with remote contact data
 */
- (instancetype)initWithDictionary:(NSDictionary*)json;

- (instancetype)initWithCNPostalAddress:(CNPostalAddress*)postalAddress type:(NSString*)type contactIdentifier:(NSString*)contactIdentifier;
- (NSDictionary*) toJSON;

+ (ContactAddress*)createFromJSON:(NSDictionary*)json;

- (NSString*)addressTypeLabel;
- (NSString*)addressKey;
- (NSString*)prettyAddress;
- (NSString*)valueForCompare;

-(id)copyWithZone:(NSZone *)zone;

@end

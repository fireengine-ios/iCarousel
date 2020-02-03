//
//  ContactAddress.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 12.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

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
@property (strong) NSNumber *contactId;
@property BOOL deleted;
@property SYNCAddressType type;

/**
 * Use this contructor to init with device contact data
 */
- (instancetype)initWithValue:(NSString*)street postalCode:(NSString *)postalCode district:(NSString *)district city:(NSString *)city country:(NSString *)country andType:(NSString*)type contactId:(NSNumber*)contactId;
/**
 * Use this contructor to init with remote contact data
 */
- (instancetype)initWithDictionary:(NSDictionary*)json;

- (instancetype)initWithRef:(NSDictionary*)dict type:(NSString*)type contactId:(NSNumber*)contactId;
- (NSDictionary*) toJSON;

+ (ContactAddress*)createFromJSON:(NSDictionary*)json;

- (CFStringRef)addressTypeLabel;
- (NSString*)addressKey;
- (NSString*)prettyAddress;
- (NSString*)valueForCompare;

-(id)copyWithZone:(NSZone *)zone;

@end

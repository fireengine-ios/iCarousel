//
//  ContactAddress.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 12.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import "ContactAddress.h"
#import <AddressBook/ABPerson.h>

@implementation ContactAddress

- (instancetype)initWithValue:(NSString*)street postalCode:(NSString *)postalCode district:(NSString *)district city:(NSString *)city country:(NSString *)country andType:(NSString*)type contactId:(NSNumber*)contactId
{
    self = [super init];
    if (self){
        self.street = street;
        self.postalCode = postalCode;
        self.district = district;
        self.city = city;
        self.country = country;
        self.contactId = contactId;
        if ([type isEqualToString:(__bridge NSString*)kABHomeLabel]){
            self.type = CADDRESS_HOME;
        } else if ([type isEqualToString:(__bridge NSString*)kABWorkLabel]){
            self.type = CADDRESS_WORK;
        } else {
            self.type = CADDRESS_OTHER;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self){
        self.remoteId = SYNC_IS_NULL(json[@"id"])?[NSNumber numberWithInt:0] : json[@"id"];
        self.street = SYNC_IS_NULL(json[@"street"]) ? nil : json[@"street"];
        self.postalCode = SYNC_IS_NULL(json[@"postalCode"]) ? nil : json[@"postalCode"];
        self.district = SYNC_IS_NULL(json[@"district"]) ? nil : json[@"district"];
        self.city = SYNC_IS_NULL(json[@"city"]) ? nil : json[@"city"];
        self.country = SYNC_IS_NULL(json[@"country"]) ? nil : json[@"country"];
        NSString *type =  SYNC_IS_NULL(json[@"type"]) ? nil : json[@"type"];
        if (type != nil){
            if([type isEqualToString:@"HOME"]){
                self.type = CADDRESS_HOME;
            }
            else if([type isEqualToString:@"WORK"]){
                self.type = CADDRESS_WORK;
            }
            else if([type isEqualToString:@"OTHER"]){
                self.type = CADDRESS_OTHER;
            }else{
                self.type = CADDRESS_OTHER;
            }
            
        }
    }
    return self;
}

- (instancetype)initWithRef:(NSDictionary*)dict type:(NSString*)type contactId:(NSNumber*)contactId
{
    self = [super init];
    if (self){
        self.street = [dict objectForKey:(__bridge NSString *)kABPersonAddressStreetKey];
        self.postalCode = [dict objectForKey:(__bridge NSString *)kABPersonAddressZIPKey];
        self.district = [dict objectForKey:(__bridge NSString *)kABPersonAddressStateKey];
        self.city = [dict objectForKey:(__bridge NSString *)kABPersonAddressCityKey];
        self.country = [dict objectForKey:(__bridge NSString *)kABPersonAddressCountryKey];
        self.contactId = contactId;
        if (type != nil){
            if([type isEqualToString:(__bridge NSString*)kABHomeLabel]){
                self.type = CADDRESS_HOME;
            }else if([type isEqualToString:(__bridge NSString*)kABWorkLabel]){
                self.type = CADDRESS_WORK;
            }else{
                self.type = CADDRESS_OTHER;
            }
        }
    }
    return self;
}

- (NSString*)addressKey
{
    NSString *value = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", self.street, self.postalCode,self.district,self.city,self.country ];
    return value;
}

- (NSString*)prettyAddress
{
    NSString *value = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", self.street, self.postalCode,self.district,self.city,self.country ];
    return value;
}

- (CFStringRef)addressTypeLabel
{
    switch (_type) {
        case CADDRESS_HOME:
            return kABHomeLabel;
        case CADDRESS_WORK:
            return kABWorkLabel;
        default:
            return kABOtherLabel;
    }
}


- (NSDictionary*) toJSON
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (!SYNC_IS_NULL(self.remoteId) && [self.remoteId integerValue]>0){
        dict[@"id"] = self.remoteId;
    }

    SYNC_SET_DICT_IF_NOT_NIL(dict, self.street, @"street");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.postalCode, @"postalCode");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.district, @"district");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.city, @"city");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.country, @"country");
    
    switch (self.type) {
        case CADDRESS_HOME:{
            dict[@"type"] = @"HOME";
            break;
        }
        case CADDRESS_WORK:{
            dict[@"type"] = @"WORK";
            break;
        }
        default:{
            dict[@"type"] = @"OTHER";
            break;
        }
    }
    
    return [dict copy];
}

+ (ContactAddress*)createFromJSON:(NSDictionary*)json
{
    return [[ContactAddress alloc] initWithDictionary:json];
}

- (BOOL)isEqual:(id)object
{
    if (self == object){
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[ContactAddress class]]){
        return NO;
    }
    ContactAddress *other = object;
    if (![[self valueForCompare] isEqualToString:[other valueForCompare]]){
        return NO;
    }
    //    if (_type != other.type){
    //        return NO;
    //    }
    return YES;
}

- (NSString *)valueForCompare{
    NSString *result = @"";
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.street)) {
        result = [result stringByAppendingString:self.street];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.postalCode)) {
        result = [result stringByAppendingString:self.postalCode];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.district)) {
        result = [result stringByAppendingString:self.district];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.city)) {
        result = [result stringByAppendingString:self.city];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.country)) {
        result = [result stringByAppendingString:self.country];
    }
    
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@")" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"(" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    ContactAddress *copy = [[ContactAddress allocWithZone: zone] init];
    [copy setRemoteId: self.remoteId];
    [copy setStreet: self.street];
    [copy setPostalCode: self.postalCode];
    [copy setDistrict: self.district];
    [copy setCity: self.city];
    [copy setCountry: self.country];
    [copy setContactId: self.contactId];
    [copy setDeleted: self.deleted];
    [copy setType: self.type];
    return copy;
}

@end

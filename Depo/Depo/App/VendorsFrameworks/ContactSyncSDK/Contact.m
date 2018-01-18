//
//  Contact.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "Contact.h"
#import "ContactDevice.h"
#import "SyncSettings.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Contact

/**
 * Use this constructor to convert address book records
 *
 * @param ref
 */
- (instancetype)initWithRecordRef:(ABRecordRef)ref
{
    self = [super init];
    if (self){
        _recordRef = ref;
        
        CFTypeRef cFirstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        CFTypeRef cMiddleName = ABRecordCopyValue(ref, kABPersonMiddleNameProperty);
        CFTypeRef cLastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        CFTypeRef cNickName = ABRecordCopyValue(ref, kABPersonNicknameProperty);
        
        _objectId = [NSNumber numberWithInt:ABRecordGetRecordID(_recordRef)];
        
        if (cFirstName!=NULL){
            _firstName=[NSString stringWithFormat:@"%@", cFirstName];
            CFRelease(cFirstName);
        }
        if (cMiddleName!=NULL){
            _middleName=[NSString stringWithFormat:@"%@", cMiddleName];
            CFRelease(cMiddleName);
        }
        if (cLastName!=NULL){
            _lastName=[NSString stringWithFormat:@"%@", cLastName];
            CFRelease(cLastName);
        }
        if (cNickName!=NULL){
            _nickName=[NSString stringWithFormat:@"%@", cNickName];
            CFRelease(cNickName);
        }

        NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(_recordRef,kABPersonModificationDateProperty));
        _localUpdateDate = SYNC_DATE_AS_NUMBER(lastModif);
        SYNC_Log(@"Last Modified Date : %@ %@ %@",_objectId, lastModif, _localUpdateDate);
        
        _devices = [NSMutableArray new];
    }
    return self;
}
/**
 * Use this constructor to convert remote records
 *
 * @param json
 */
- (instancetype)initWithDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self){
        if(!SYNC_IS_NULL(json[@"localId"])){
            _objectId = json[@"localId"];
        }
        _remoteId = json[@"id"];
        _firstName = json[@"firstname"];
        _middleName = json[@"middlename"];
        _lastName = json[@"lastname"];
        _nickName = json[@"nickname"];
        _displayName = json[@"displayname"];
        
        _remoteUpdateDate = json[@"modified"];
        
        _devices = [NSMutableArray new];
        if (!SYNC_IS_NULL(json[@"devices"])){
            NSArray *data = json[@"devices"];
            NSMutableSet *devices = [NSMutableSet new];
            for (NSDictionary *item in data){
                ContactDevice *device = [ContactDevice createFromJSON:item];
                if (device!=nil){
                    [devices addObject:device];
                }
            }
            [_devices addObjectsFromArray:[devices allObjects]];
        }

    }
    return self;
}

/**
 * Use this constructor to convert remote records
 *
 * @param json
 */
- (instancetype)initWithCopy:(NSDictionary*)json
{
    if (self = [super init]){
        _objectId = [json[@"localId"] copy];
        _remoteId = [json[@"id"] copy];
        _firstName = [json[@"firstname"] copy];
        _middleName = [json[@"middlename"] copy];
        _lastName = [json[@"lastname"] copy];
        _nickName = [json[@"nickname"] copy];
        _displayName = [json[@"displayname"] copy];
        _remoteUpdateDate = [json[@"modified"] copy];
        _hasName = [json[@"hasName"] boolValue];
        _hasPhoneNumber = [json[@"hasNumber"] boolValue];
        _devices = [json[@"devices"] mutableCopy];
    }
    return self;
}

/*
 * isNewContact should be true while "Mode:Restore" is adding new contact.
 */
- (NSDictionary*) toJSON:(BOOL)isNewContact
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (!SYNC_IS_NULL(self.remoteId) && [self.remoteId integerValue]>0){
        dict[@"id"] = self.remoteId;
    }

    SYNC_SET_DICT_IF_NOT_NIL(dict, self.firstName, @"firstname");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.middleName, @"middlename");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.nickName, @"nickname");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.lastName, @"lastname");
    if(isNewContact)
        SYNC_SET_DICT_IF_NOT_NIL(dict, self.objectId, @"localId");
    
    NSMutableArray *array = [NSMutableArray new];
    for (ContactDevice *device in _devices){
        NSDictionary *item = [device toJSON];
        [array addObject:item];
    }
    dict[@"devices"] = array;
    
    return dict;
}

- (NSString*) toStringValue{
    NSMutableString *value = [NSMutableString new];
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.firstName);
    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.middleName);
    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.nickName);
    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.lastName);
    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    
    NSMutableArray *ary = [NSMutableArray arrayWithArray:_devices];
    NSArray *sorted = [ary sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContactDevice *d1 = (ContactDevice*)obj1;
        ContactDevice *d2 = (ContactDevice*)obj2;
        return [d1.value compare:d2.value options:NSNumericSearch];
    }];
    
    for (ContactDevice *device in sorted){
        SYNC_APPEND_STRING_IF_NOT_NIL(value, device.value);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, ([NSString stringWithFormat:@"%lu", (unsigned long)device.type]));
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    }
    return [value copy];
}

-(NSString *)toMD5
{
    NSString *contactString = [self toStringValue];
    const char *contactChars = [contactString UTF8String];
    unsigned char contactMD5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(contactChars, strlen(contactChars),  contactMD5);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", contactMD5[i]];
    return output;
}

- (BOOL)preEqualCheck:(id)object
{
    if (self == object){
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[Contact class]]){
        return NO;
    }
    Contact *other = object;
    if (SYNC_IS_NULL(_firstName)){
        if (!SYNC_IS_NULL(other.firstName) && other.firstName.length!=0){
            return NO;
        }
    } else if (![_firstName isEqualToString:other.firstName]){
        return NO;
    }
    if (SYNC_IS_NULL(_middleName)){
        if (!SYNC_IS_NULL(other.middleName) && other.middleName.length!=0){
            return NO;
        }
    } else if (![_middleName isEqualToString:other.middleName]){
        return NO;
    }
    if (SYNC_IS_NULL(_nickName)){
        if (!SYNC_IS_NULL(other.nickName) && other.nickName.length!=0){
            return NO;
        }
    } else if (![_nickName isEqualToString:other.nickName]){
        return NO;
    }
    if (SYNC_IS_NULL(_lastName)){
        if (!SYNC_IS_NULL(other.lastName) && other.lastName.length!=0){
            return NO;
        }
    } else if (![_lastName isEqualToString:other.lastName]){
        return NO;
    }
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if (self == object){
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[Contact class]]){
        return NO;
    }
    Contact *other = object;
    if (![[self generateDisplayName] isEqualToString:[other generateDisplayName]]) {
        return NO;
    }
    if (SYNC_IS_NULL(_devices)){
        if (!SYNC_IS_NULL(other.devices)){
            return NO;
        }
    } else {
        if (SYNC_IS_NULL(other.devices)){
            return NO;
        }
        if ([_devices count] < [other.devices count]){
            return NO;
        }
        
        NSMutableSet *phoneIdSet = [NSMutableSet new];
        NSMutableSet *emailIdSet = [NSMutableSet new];
        for (ContactDevice *device in _devices){
            NSString *key = [device deviceKey];
            if ([device isKindOfClass:[ContactPhone class]]){
                [phoneIdSet addObject:key];
            } else {
                [emailIdSet addObject:key];
            }
        }
        
        for (int i=0;i<[other.devices count];i++){
            ContactDevice *device = other.devices[i];
            NSString *key = [device deviceKey];
            if ([device isKindOfClass:[ContactEmail class]]){
                if (![emailIdSet containsObject:key]){
                    return NO;
                }
            } else {
                if (![phoneIdSet containsObject:key]){
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (NSString*)generateDisplayName
{
    NSMutableString *displayName=[[NSMutableString alloc]init];
    
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.firstName)){
        [displayName appendString:self.firstName];
        [displayName appendString:@" "];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.middleName)){
        [displayName appendString:self.middleName];
        [displayName appendString:@" "];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.nickName)){
        [displayName appendString:[NSString stringWithFormat:@"\"%@\"",self.nickName]];
        [displayName appendString:@" "];
    }
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(self.lastName)){
        [displayName appendString:self.lastName];
        [displayName appendString:@" "];
    }
    
    return [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) copyContact:(Contact *)contact
{
    _firstName = contact.firstName;
    _middleName = contact.middleName;
    _nickName = contact.nickName;
    _lastName = contact.lastName;
    for (ContactDevice *d in contact.devices){
        if (![_devices containsObject:d]){
            [_devices addObject:d];
        }
    }
}

-(BOOL)isDeviceSizeEqual:(Contact*)other{
    if(SYNC_IS_NULL(self.devices)){
        if (!SYNC_IS_NULL(other.devices)) {
            return NO;
        }
    }else{
        if (SYNC_IS_NULL(other.devices)) {
            return NO;
        }
        
        NSMutableSet *thisSet = [NSMutableSet new];
        NSMutableSet *otherSet = [NSMutableSet new];
        for (ContactDevice *device in _devices){
            NSString *key = [device deviceKey];
            [thisSet addObject:key];
        }
        for (ContactDevice *device in other.devices){
            NSString *key = [device deviceKey];
            [otherSet addObject:key];
        }
        
        if ([thisSet count] != [otherSet count]){
            return NO;
        }
    }
    
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {

    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _objectId ?: [NSNull null], @"localId",
                          _remoteId ?: [NSNull null], @"id",
                          _firstName ?: [NSNull null], @"firstname",
                          _middleName ?: [NSNull null], @"middlename",
                          _lastName ?: [NSNull null], @"lastname",
                          _nickName ?: [NSNull null], @"nickname",
                          _displayName ?: [NSNull null], @"displayname",
                          _remoteUpdateDate ?: [NSNull null], @"modified",
                          _devices ?: [NSNull null], @"devices",
                          @(_hasName) ?: [NSNull null], @"hasName",
                          @(_hasPhoneNumber) ?: [NSNull null], @"hasNumber",
                          nil];

    Contact *contact = [self initWithCopy:data];
    contact.recordRef = _recordRef;

    return contact;
}

@end

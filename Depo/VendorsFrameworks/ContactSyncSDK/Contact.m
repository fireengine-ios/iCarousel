//
//  Contact.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "Contact.h"
#import "ContactDevice.h"
#import "ContactAddress.h"
#import "SyncSettings.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Contact

- (instancetype)initWithCNContact:(CNContact *)cnContact {
    self = [super init];
    if (self) {
        
        NSString *cFirstName = cnContact.givenName;
        NSString *cMiddleName = cnContact.middleName;
        NSString *cLastName = cnContact.familyName;
        NSString *cNickName = cnContact.nickname;
        NSString *cCompany = cnContact.organizationName;
//        NSString *cNote= cnContact.note;
        NSDateComponents *cBirthday = cnContact.birthday;
        
        _objectIdentifier = cnContact.identifier;
        
        if (!SYNC_IS_NULL(cFirstName)) {
            _firstName=[NSString stringWithFormat:@"%@", cFirstName];
        }
        if (!SYNC_IS_NULL(cMiddleName)){
            _middleName=[NSString stringWithFormat:@"%@", cMiddleName];
        }
        if (!SYNC_IS_NULL(cLastName)){
            _lastName=[NSString stringWithFormat:@"%@", cLastName];
        }
        if (!SYNC_IS_NULL(cNickName)){
            _nickName=[NSString stringWithFormat:@"%@", cNickName];
        }
        if (!SYNC_IS_NULL(cCompany)){
            _company=[NSString stringWithFormat:@"%@", cCompany];
        }
//        if (!SYNC_IS_NULL(cNote)){
//            _note=[NSString stringWithFormat:@"%@", cNote];
//        }
        if (!SYNC_IS_NULL(cBirthday)){
            
            NSCalendar* calendar = [NSCalendar  currentCalendar];
            NSDate* date = [calendar dateFromComponents:cBirthday];
            NSDateComponents *dateComponents =
            [calendar components:(NSYearCalendarUnit  |
                                  NSMonthCalendarUnit |
                                  NSDayCalendarUnit   ) fromDate:date];
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            
            if(dateComponents.year<1800){
                
                dateComponents.year=components.year;
            }
            
            NSDate *currentYearDate=[calendar dateFromComponents:dateComponents];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy/MM/dd";
            NSString *dateString = [dateFormatter stringFromDate:currentYearDate];
            
            _birthday=[NSString stringWithFormat:@"%@",dateString ];
            
        }
        
        SYNC_Log(@"Identifier: %@", _objectIdentifier);
        
        _devices = [NSMutableArray new];
        _addresses = [NSMutableArray new];
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
            _objectIdentifier = json[@"localId"];
        }
        _remoteId = json[@"id"];
        _firstName = json[@"firstname"];
        _middleName = json[@"middlename"];
        _lastName = json[@"lastname"];
        _nickName = json[@"nickname"];
        _displayName = json[@"displayname"];
        _company = json[@"company"];
//        _note = json[@"note"];
        _birthday = json[@"birthday"];
        
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
        
        _addresses = [NSMutableArray new];
        if (!SYNC_IS_NULL(json[@"addresses"])){
            NSArray *data = json[@"addresses"];
            NSMutableSet *addresses = [NSMutableSet new];
            for (NSDictionary *item in data){
                ContactAddress *address = [ContactAddress createFromJSON:item];
                if (address!=nil){
                    [addresses addObject:address];
                }
            }
            [_addresses addObjectsFromArray:[addresses allObjects]];
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
        _objectIdentifier = [json[@"localId"] copy];
        _remoteId = [json[@"id"] copy];
        _firstName = [json[@"firstname"] copy];
        _middleName = [json[@"middlename"] copy];
        _lastName = [json[@"lastname"] copy];
        _nickName = [json[@"nickname"] copy];
        _displayName = [json[@"displayname"] copy];
        _company = [json[@"company"] copy];
        _remoteUpdateDate = [json[@"modified"] copy];
        _hasName = [json[@"hasName"] boolValue];
        _hasPhoneNumber = [json[@"hasNumber"] boolValue];
        _devices = [json[@"devices"] mutableCopy];
        _addresses = [json[@"addresses"] mutableCopy];
        
//        _note = [json[@"note"] copy];
        _birthday =[json[@"birthday"] copy];
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
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.company, @"company");
//    SYNC_SET_DICT_IF_NOT_NIL(dict, self.note, @"note");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.birthday, @"birthday");
    if(isNewContact)
        SYNC_SET_DICT_IF_NOT_NIL(dict, self.objectIdentifier, @"localId");
    
    NSMutableArray *array = [NSMutableArray new];
    for (ContactDevice *device in _devices){
        NSDictionary *item = [device toJSON];
        [array addObject:item];
    }
    dict[@"devices"] = array;
    
    NSMutableArray *addressArray = [NSMutableArray new];
    for (ContactAddress *address in _addresses){
        NSDictionary *item = [address toJSON];
        [addressArray addObject:item];
    }
    dict[@"addresses"] = addressArray;
    
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
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.company);
    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
//    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.note);
//    SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
    SYNC_APPEND_STRING_IF_NOT_NIL(value, self.birthday);
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
    
    NSMutableArray *ary1 = [NSMutableArray arrayWithArray:_addresses];
    NSArray *sorted1 = [ary1 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ContactAddress *d1 = (ContactAddress*)obj1;
        ContactAddress *d2 = (ContactAddress*)obj2;
        return [d1.addressKey compare:d2.addressKey options:NSNumericSearch];
    }];
    
    for (ContactAddress *address in sorted1){
        SYNC_APPEND_STRING_IF_NOT_NIL(value, address.street);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, address.postalCode);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, address.district);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, address.city);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, address.country);
        SYNC_APPEND_STRING_IF_NOT_NIL(value, @";");
        SYNC_APPEND_STRING_IF_NOT_NIL(value, ([NSString stringWithFormat:@"%lu", (unsigned long)address.type]));
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
    if (SYNC_IS_NULL(_company)){
        if (!SYNC_IS_NULL(other.company) && other.company.length!=0){
            return NO;
        }
    } else if (![_company isEqualToString:other.company]){
        return NO;
    }
//    if (SYNC_IS_NULL(_note)){
//        if (!SYNC_IS_NULL(other.note) && other.note.length!=0){
//            return NO;
//        }
//    } else if (![_note isEqualToString:other.note]){
//        return NO;
//    }
    
    if (SYNC_IS_NULL(_birthday)){
        if (!SYNC_IS_NULL(other.birthday) && other.birthday.length!=0){
            return NO;
        }
    } else if (![_birthday isEqualToString:other.birthday]){
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
    if (SYNC_IS_NULL(_company)){
        if (!SYNC_IS_NULL(other.company)){
            return NO;
        }
    }else{
        if (SYNC_IS_NULL(other.company) || ![_company isEqualToString:other.company]){
            return NO;
        }
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
    
    if (SYNC_IS_NULL(_addresses)){
        if (!SYNC_IS_NULL(other.addresses)){
            return NO;
        }
    } else {
        if (SYNC_IS_NULL(other.addresses)){
            return NO;
        }
        if ([_addresses count] < [other.addresses count]){
            return NO;
        }
        
        NSMutableSet *addressSet = [NSMutableSet new];
        for (ContactAddress *address in _addresses){
            NSString *key = [address addressKey];
            [addressSet addObject:key];
        }
        
        for (int i=0;i<[other.addresses count];i++){
            ContactAddress *address = other.addresses[i];
            NSString *key = [address addressKey];
            if (![addressSet containsObject:key]){
                return NO;
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
    _company = contact.company;
//    _note = contact.note;
    _birthday =contact.birthday;
    for (ContactDevice *d in contact.devices){
        if (![_devices containsObject:d]){
            [_devices addObject:d];
        }
    }
    for (ContactAddress *d in contact.addresses){
        if (![_addresses containsObject:d]){
            [_addresses addObject:d];
        }
    }
}

-(void)deepCopy:(Contact *)contact
{
    _objectIdentifier = contact.objectIdentifier;
    _remoteId = contact.remoteId;
    _firstName = contact.firstName;
    _middleName = contact.middleName;
    _lastName = contact.lastName;
    _nickName = contact.nickName;
    _displayName = contact.displayName;
    _company = contact.company;
    _remoteUpdateDate = contact.remoteUpdateDate;
    _hasName = contact.hasName;
    _hasPhoneNumber = contact.hasPhoneNumber;
    _devices = contact.devices;
    _addresses = contact.addresses;
//    _note = contact.note;
    _birthday = contact.birthday;
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
                          _objectIdentifier ?: [NSNull null], @"localId",
                          _remoteId ?: [NSNull null], @"id",
                          _firstName ?: [NSNull null], @"firstname",
                          _middleName ?: [NSNull null], @"middlename",
                          _lastName ?: [NSNull null], @"lastname",
                          _nickName ?: [NSNull null], @"nickname",
                          _company ?: [NSNull null], @"company",
                          _displayName ?: [NSNull null], @"displayname",
                          _remoteUpdateDate ?: [NSNull null], @"modified",
                          _devices ?: [NSNull null], @"devices",
                          _addresses ?: [NSNull null], @"addresses",
                          @(_hasName) ?: [NSNull null], @"hasName",
                          @(_hasPhoneNumber) ?: [NSNull null], @"hasNumber",
//                          _note ?: [NSNull null], @"note",
                          _birthday ?: [NSNull null], @"birthday",
                          
                          nil];
    
    Contact *contact = [self initWithCopy:data];
    
    return contact;
}

- (NSString *)nameForCompare {
    NSString *val = [self generateDisplayName];
    val = [val lowercaseString];
    val = [val stringByReplacingOccurrencesOfString:@" " withString:@""];
    val = [val stringByReplacingOccurrencesOfString:@"ü" withString:@"u"];
    val = [val stringByReplacingOccurrencesOfString:@"ı" withString:@"i"];
    val = [val stringByReplacingOccurrencesOfString:@"ö" withString:@"o"];
    val = [val stringByReplacingOccurrencesOfString:@"ş" withString:@"s"];
    val = [val stringByReplacingOccurrencesOfString:@"ğ" withString:@"g"];
    val = [val stringByReplacingOccurrencesOfString:@"ç" withString:@"c"];
    return val;
}

- (BOOL)containsSameDevice:(Contact *)contact {
    if ((self.devices == nil || self.devices.count == 0) || (contact.devices == nil || contact.devices.count == 0)) {
        return true;
    }
    
    for(ContactDevice *device in self.devices) {
        for(ContactDevice *device1 in contact.devices) {
            if([device class] != [device1 class]){
                continue;
            }
            if (!SYNC_STRING_IS_NULL_OR_EMPTY([device value]) && !SYNC_STRING_IS_NULL_OR_EMPTY([device1 value])) {
                if ([device.valueForCompare isEqualToString:device1.valueForCompare]) {
                    return true;
                }
            }
        }
    }
    
    return false;
}

- (BOOL)nameEquals:(Contact *)contact {
    return !SYNC_STRING_IS_NULL_OR_EMPTY(self.nameForCompare) && !SYNC_STRING_IS_NULL_OR_EMPTY(contact.nameForCompare) && [self.nameForCompare isEqualToString:contact.nameForCompare];
}

@end

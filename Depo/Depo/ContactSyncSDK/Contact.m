//
//  Contact.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "Contact.h"
#import "ContactDevice.h"
#import "SyncSettings.h"

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
        
        _objectId = [NSNumber numberWithInt:ABRecordGetRecordID(_recordRef)];
        _firstName=(__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        _middleName=(__bridge NSString*)ABRecordCopyValue(ref, kABPersonMiddleNameProperty);
        _lastName=(__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);

        NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(_recordRef,kABPersonModificationDateProperty));
        SYNC_Log(@"Last Modified Date : %@ %@ %@",_firstName, _lastName, lastModif);
        _localUpdateDate = SYNC_DATE_AS_NUMBER(lastModif);
        
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
        _remoteId = json[@"id"];
        _firstName = json[@"firstname"];
        _middleName = json[@"middlename"];
        _lastName = json[@"lastname"];
        
        if (!SYNC_IS_NULL(json[@"managementInfo"])){
            NSDictionary *info = json[@"managementInfo"];
            _remoteUpdateDate = info[@"updateDate"];
        } else {
            _remoteUpdateDate = [NSNumber numberWithInt:0];
        }
        
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

- (NSDictionary*) toJSON
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (!SYNC_IS_NULL(self.remoteId) && [self.remoteId integerValue]>0){
        dict[@"id"] = self.remoteId;
    }
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.firstName, @"firstname");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.middleName, @"middlename");
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.lastName, @"lastname");

    NSMutableSet *emailTypes= [[NSMutableSet alloc]initWithArray:@[
                                 [NSNumber numberWithInteger:CDEVICE_HOME],
                                 [NSNumber numberWithInteger:CDEVICE_WORK],
                                 [NSNumber numberWithInteger:CDEVICE_OTHER],
                                 ]];
    
    NSMutableSet *phoneTypes =[[NSMutableSet alloc]initWithArray:@[
                                 [NSNumber numberWithInteger:CDEVICE_HOME],
                                 [NSNumber numberWithInteger:CDEVICE_MOBILE],
                                 [NSNumber numberWithInteger:CDEVICE_WORK],
                                 [NSNumber numberWithInteger:CDEVICE_WORK_MOBILE],
                                 [NSNumber numberWithInteger:CDEVICE_OTHER]
                                 ,]];
    NSMutableArray *duplicated=[[NSMutableArray alloc] init];
    
    for (ContactDevice *device in _devices) {
        if ([device isKindOfClass:[ContactPhone class]]) {
            if ([phoneTypes containsObject:[NSNumber numberWithInteger:device.type]]) {
                [phoneTypes removeObject:[NSNumber numberWithInteger:device.type]];
            }else{
                [duplicated addObject:device];
            }
        }else{
            if ([emailTypes containsObject:[NSNumber numberWithInteger:device.type]]) {
                [emailTypes removeObject:[NSNumber numberWithInteger:device.type]];
            }else{
                [duplicated addObject:device];
            }
        }
    }
    
    NSMutableArray *remainingPhone = [[NSMutableArray alloc] initWithArray: [phoneTypes allObjects]];
    NSMutableArray *remainingEmail = [[NSMutableArray alloc] initWithArray: [emailTypes allObjects]];
    if (duplicated.count>0) {
        for (ContactDevice *device in duplicated) {
            if ([device isKindOfClass:[ContactPhone class]]) {
                if (remainingPhone.count>0) {
                    device.type=(SYNCDeviceType)[[remainingPhone firstObject] integerValue];
                    [remainingPhone removeObjectAtIndex:0];
                }
            }else{
                if (remainingEmail.count>0) {
                    device.type=(SYNCDeviceType)[[remainingEmail firstObject] integerValue];
                    [remainingEmail removeObjectAtIndex:0];
                }
            }
        }
    }
    
    NSMutableArray *array = [NSMutableArray new];
    for (ContactDevice *device in _devices){
        NSDictionary *item = [device toJSON];
        [array addObject:item];
    }
    dict[@"devices"] = array;
    
    return dict;
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
    if (![[self displayName] isEqualToString:[other displayName]]) {
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

- (NSString*)displayName
{
    NSMutableString *displayName=[[NSMutableString alloc]init];
    if (SYNC_STRING_IS_NULL_OR_EMPTY(self.middleName)){
        [displayName appendString:[NSString stringWithFormat:@"%@ %@",(SYNC_IS_NULL(self.firstName)?@"":self.firstName), (SYNC_IS_NULL(self.lastName)?@"":self.lastName)]];
    } else {
        [displayName appendString:[NSString stringWithFormat:@"%@ %@ %@",(SYNC_IS_NULL(self.firstName)?@"":self.firstName), self.middleName, (SYNC_IS_NULL(self.lastName)?@"":self.lastName)]];
    }
    
    return [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) copyContact:(Contact *)contact
{
    _firstName = contact.firstName;
    _middleName = contact.middleName;
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
@end

//
//  ContactDevice.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactDevice.h"
#import "ContactUtil.h"
#import "SyncSettings.h"

@implementation ContactDevice

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type contactIdentifier:(NSString *)contactIdentifier
{
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)json
{
    return nil;
}

- (NSDictionary*) toJSON
{
    return nil;
}

- (NSString*)deviceKey
{
    NSString *value = self.valueForCompare;
    return value;
}

- (NSString*)deviceTypeLabel
{
    switch (_type) {
        case CDEVICE_HOME:
            return CNLabelHome;
        case CDEVICE_MOBILE:
        case CDEVICE_WORK_MOBILE:
            return CNLabelPhoneNumberMobile;
        case CDEVICE_WORK:
            return CNLabelWork;
        default:
            return CNLabelOther;
    }
}

+ (ContactDevice*)createFromJSON:(NSDictionary*)json
{
    if (SYNC_IS_NULL(json[@"category"])){
        return nil;
    } else {
        NSString *type = json[@"category"];
        if ([@"PHONE" isEqualToString:type]){
            return [[ContactPhone alloc] initWithDictionary:json];
        } else if ([@"EMAIL" isEqualToString:type]){
            return [[ContactEmail alloc] initWithDictionary:json];
        } else {
            return nil;
        }
    }
}

- (NSUInteger)hash
{
    static int prime = 31;
    unsigned long result = 1;
    result = prime * result + ((_value == nil) ? 0 : [[self valueForCompare] hash]);
//    result = prime * result + ((_type == 0) ? 0 : _type);
    return result;
}

- (BOOL)isEqual:(id)object
{
    if (self == object){
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[ContactDevice class]]){
        return NO;
    }
    ContactDevice *other = object;
    if (SYNC_IS_NULL(_value)){
        if (!SYNC_IS_NULL(other.value)){
            return NO;
        }
    } else if (SYNC_IS_NULL(other.value)){
        return NO;
    } else if (![[self valueForCompare] isEqualToString:[other valueForCompare]]){
        return NO;
    }
//    if (_type != other.type){
//        return NO;
//    }
    return YES;
}

- (NSString *)valueForCompare {
    return nil;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ContactDevice *copy = [[ContactDevice allocWithZone: zone] init];
    [copy setRemoteId: self.remoteId];
    [copy setValue: self.value];
    [copy setDeleted: self.deleted];
    [copy setContactIdentifier:self.contactIdentifier];
    [copy setType: self.type];
    return copy;
}

@end

@implementation  ContactPhone

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type contactIdentifier:(NSString *)contactIdentifier {
    self = [super init];
    if (self){
        self.value = value;
        self.contactIdentifier = contactIdentifier;
        if ([type isEqualToString:CNLabelHome]){
            self.type = CDEVICE_HOME;
        } else if ([type isEqualToString:CNLabelPhoneNumberMobile]){
            self.type = CDEVICE_MOBILE;
        } else if ([type isEqualToString:CNLabelWork])
        {
            self.type = CDEVICE_WORK;
        } else
        {
            self.type = CDEVICE_OTHER;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self){
        self.remoteId = SYNC_IS_NULL(json[@"id"])?[NSNumber numberWithInt:0] : json[@"id"];
        self.value = SYNC_IS_NULL(json[@"value"]) ? nil : json[@"value"];
        NSString *type =  SYNC_IS_NULL(json[@"type"]) ? nil : json[@"type"];
        if (type != nil){
            if([type isEqualToString:@"HOME"]){
                self.type = CDEVICE_HOME;
            }
            else if([type isEqualToString:@"WORK"]){
                self.type = CDEVICE_WORK;
            }
            else if([type isEqualToString:@"MOBILE"]){
                self.type = CDEVICE_MOBILE;
            }
            else if([type isEqualToString:@"OTHER"]){
                self.type = CDEVICE_OTHER;
            }else{
                self.type = CDEVICE_OTHER;
            }
        
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
    dict[@"category"] = @"PHONE";
    
    SYNC_SET_DICT_IF_NOT_NIL(dict, self.value, @"value");
    
    switch (self.type) {
        case CDEVICE_HOME:{
            dict[@"type"] = @"HOME";
            break;
        }
        case CDEVICE_WORK:{
            dict[@"type"] = @"WORK";
            break;
        }
        case CDEVICE_WORK_MOBILE:{
            dict[@"type"] = @"WORK";
            break;
        }
        case CDEVICE_MOBILE:{
            dict[@"type"] = @"MOBILE";
            break;
        }
        default:{
            dict[@"type"] = @"OTHER";
            break;
        }
    }
    
    return [dict copy];
}

- (NSString*) getCompareValue:(BOOL)save{
    NSString *val = self.value;
    if (!SYNC_STRING_IS_NULL_OR_EMPTY(val)){
        val = [val stringByReplacingOccurrencesOfString:@" " withString:@""];
        val = [val stringByReplacingOccurrencesOfString:@"(" withString:@""];
        val = [val stringByReplacingOccurrencesOfString:@")" withString:@""];
        val = [val stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        if (save){
            if ([val hasPrefix:@"+"]){
                val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"" options:0 range:[val rangeOfString:@"+"]];
            }
        }else{
            if ([val hasPrefix:@"0"]){
                val = [val stringByReplacingOccurrencesOfString:@"0" withString:@"" options:0 range:[val rangeOfString:@"0"]];
            }
            if (!SYNC_STRING_IS_NULL_OR_EMPTY([SyncSettings shared].countryCode)){
                if ([val hasPrefix:@"+"]){
                    val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"" options:0 range:[val rangeOfString:@"+"]];
                }
                if ([val hasPrefix:[SyncSettings shared].countryCode]){
                    val = [val stringByReplacingOccurrencesOfString:[SyncSettings shared].countryCode withString:@"" options:0 range:[val rangeOfString:[SyncSettings shared].countryCode]];
                }
            }
            
        }
    }
    
    return val;
}

- (NSString *)valueForCompare{
    NSString* val = self.value;
    if (val != nil) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
        val = [regex stringByReplacingMatchesInString:val options:0 range:NSMakeRange(0, [val length]) withTemplate:@""];
        if ([val length] >= 11) {
            NSUInteger startIndex = [val length] - 11;
            NSUInteger length = [val length] - startIndex;
            val = [val substringWithRange:NSMakeRange(startIndex, length)];
        }
    }
    return val;
}

- (id)copyWithZone:(NSZone *)zone {
    ContactPhone *copy = [[ContactPhone allocWithZone: zone] init];
    [copy setRemoteId: self.remoteId];
    [copy setValue: self.value];
    [copy setDeleted: self.deleted];
    [copy setContactIdentifier: self.contactIdentifier];
    [copy setType: self.type];
    return copy;
}

@end

@implementation ContactEmail

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type contactIdentifier:(NSString *)contactIdentifier {
    self = [super init];
    if (self){
        self.value = value;
        self.contactIdentifier = contactIdentifier;
        if ([type isEqualToString:CNLabelHome]){
            self.type = CDEVICE_HOME;
        } else if ([type isEqualToString:CNLabelWork])
        {
            self.type = CDEVICE_WORK;
        } else
        {
            self.type = CDEVICE_OTHER;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self){
        self.remoteId = SYNC_IS_NULL(json[@"id"])?[NSNumber numberWithInt:0] : json[@"id"];
        self.value = SYNC_IS_NULL(json[@"value"]) ? nil : json[@"value"];
        NSString *type =  SYNC_IS_NULL(json[@"type"]) ? nil : json[@"type"];
        if (type != nil){
            if([type isEqualToString:@"HOME"]){
                self.type = CDEVICE_HOME;
            }
            else if([type isEqualToString:@"WORK"]){
                self.type = CDEVICE_WORK;
            }
            else if([type isEqualToString:@"OTHER"]){
                self.type = CDEVICE_OTHER;
            }else{
                self.type = CDEVICE_OTHER;
            }
            
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
    dict[@"value"] = self.value;
    dict[@"category"] = @"EMAIL";
    
    switch (self.type) {
        case CDEVICE_HOME:{
            dict[@"type"] = @"HOME";
            break;
        }
        case CDEVICE_WORK:{
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

- (NSString *)valueForCompare {
    NSString* val = self.value;
    if (val != nil) {
        val = [val stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return val;
}

- (id)copyWithZone:(NSZone *)zone {
    ContactEmail *copy = [[ContactEmail allocWithZone: zone] init];
    [copy setRemoteId: self.remoteId];
    [copy setValue: self.value];
    [copy setDeleted: self.deleted];
    [copy setContactIdentifier: self.contactIdentifier];
    [copy setType: self.type];
    return copy;
}

@end

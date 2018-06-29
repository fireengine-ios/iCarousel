//
//  ContactDevice.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactDevice.h"
#import "ContactUtil.h"
#import <AddressBook/ABPerson.h>

@implementation ContactDevice

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type
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
    NSString *value = self.value;
    if ([self isKindOfClass:[ContactPhone class]]){
        value = [ContactUtil clearMsisdn:self.value];
    }
    return value;
}

- (CFStringRef)deviceTypeLabel
{
    switch (_type) {
        case CDEVICE_HOME:
            return kABHomeLabel;
        case CDEVICE_MOBILE:
        case CDEVICE_WORK_MOBILE:
            return kABPersonPhoneMobileLabel;
        case CDEVICE_WORK:
            return kABWorkLabel;
        default:
            return kABOtherLabel;
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
    result = prime * result + ((_value == nil) ? 0 : [[self deviceKey] hash]);
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
    } else if (![[self deviceKey] isEqualToString:[other deviceKey]]){
        return NO;
    }
//    if (_type != other.type){
//        return NO;
//    }
    return YES;
}

@end

@implementation  ContactPhone

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type
{
    self = [super init];
    if (self){
        self.value = value;
        if ([type isEqualToString:(__bridge NSString*)kABHomeLabel]){
            self.type = CDEVICE_HOME;
        } else if ([type isEqualToString:(__bridge NSString*)kABPersonPhoneMobileLabel]){
            self.type = CDEVICE_MOBILE;
        } else if ([type isEqualToString:(__bridge NSString*)kABWorkLabel])
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

@end

@implementation ContactEmail

- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type
{
    self = [super init];
    if (self){
        self.value = value;
        if ([type isEqualToString:(__bridge NSString*)kABHomeLabel]){
            self.type = CDEVICE_HOME;
        } else if ([type isEqualToString:(__bridge NSString*)kABWorkLabel])
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

@end

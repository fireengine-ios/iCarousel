//
//  ContactDevice.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"


typedef NS_ENUM(NSUInteger, SYNCDeviceType) {
    CDEVICE_HOME,
    CDEVICE_MOBILE,
    CDEVICE_WORK,
    CDEVICE_WORK_MOBILE,
    CDEVICE_OTHER
};

@interface ContactDevice : NSObject<NSCopying>

@property (strong) NSNumber *remoteId;
@property (strong) NSString *value;
@property BOOL deleted;
@property (strong) NSNumber *contactId;
@property SYNCDeviceType type;

/**
 * Use this contructor to init with device contact data
 */
- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type contactId:(NSNumber*)contactId;
/**
 * Use this contructor to init with remote contact data
 */
- (instancetype)initWithDictionary:(NSDictionary*)json;
- (NSDictionary*) toJSON;

+ (ContactDevice*)createFromJSON:(NSDictionary*)json;

- (CFStringRef)deviceTypeLabel;
- (NSString*)deviceKey;
- (NSString*)valueForCompare;

-(id)copyWithZone:(NSZone *)zone;

@end

@interface ContactPhone : ContactDevice
- (NSString*) getCompareValue:(BOOL)save;
@end

@interface ContactEmail : ContactDevice

@end

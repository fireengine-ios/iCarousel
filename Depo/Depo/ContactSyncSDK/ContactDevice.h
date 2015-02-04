//
//  ContactDevice.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
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

@interface ContactDevice : NSObject

@property (strong) NSNumber *remoteId;
@property (strong) NSString *value;
@property SYNCDeviceType type;

/**
 * Use this contructor to init with device contact data
 */
- (instancetype)initWithValue:(NSString*)value andType:(NSString*)type;
/**
 * Use this contructor to init with remote contact data
 */
- (instancetype)initWithDictionary:(NSDictionary*)json;
- (NSDictionary*) toJSON;

+ (ContactDevice*)createFromJSON:(NSDictionary*)json;

- (CFStringRef)deviceTypeLabel;

@end

@interface ContactPhone : ContactDevice

@end

@interface ContactEmail : ContactDevice

@end

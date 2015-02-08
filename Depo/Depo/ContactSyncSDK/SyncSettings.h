//
//  SyncSettings.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "SyncStatus.h"

typedef NS_ENUM(NSUInteger, SYNCEnvironment) {
    SYNCDevelopmentEnvironment,
    SYNCTestEnvironment,
    SYNCProductionEnvironment
};

@interface SyncSettings : NSObject

/**
 * Setting this value true activates debug behavior. This value
 * always should be false in production versions.
 */
@property BOOL debug;

/**
 * Custom url for endpoint
 */
@property (strong) NSString *url;
@property SYNCEnvironment environment;
/**
 * MSISDN of user. Either this value or token is required
 */
@property NSString *msisdn;
/**
 * Auth token. Either this value or msisdn is required
 */
@property NSString *token;
/**
 * Sync interval in minutes.
 */
@property NSTimeInterval syncInterval;
@property (nonatomic, copy) void (^callback)(void);

+ (SYNC_INSTANCETYPE) shared;

/**
 * Returns endpoint url for synchronization server. If url is provided, it's used. Otherwise
 * selects a suitable url among predefined urls based on environment value
 */
- (NSString*) endpointUrl;

@end

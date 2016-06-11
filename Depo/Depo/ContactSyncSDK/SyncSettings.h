//
//  SyncSettings.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "SyncStatus.h"

typedef NS_ENUM(NSUInteger, SYNCEnvironment) {
    SYNCDevelopmentEnvironment,
    SYNCTestEnvironment,
    SYNCProductionEnvironment
};
typedef NS_ENUM(NSUInteger, SYNCMode) {
    SYNCBackup,
    SYNCRestore
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
 * Sync mode. It has possible two value: BACKUP and RESTORE
 */
@property (nonatomic) SYNCMode mode;
/**
 * Auth token.
 */
@property NSString *token;
/**
 * For internal use only
 */
@property NSString *msisdn;
/**
 * Sync interval in minutes.
 */
@property NSTimeInterval syncInterval;
/**
 * Sync delay in minutes.
 */
@property (nonatomic) NSTimeInterval delayInterval;
/**
 * Sync periodically. Period can be adjusted using syncInterval
 */
@property (nonatomic) BOOL periodicSync;

@property (nonatomic, copy) void (^callback)(id data);

+ (SYNC_INSTANCETYPE) shared;

/**
 * Returns endpoint url for synchronization server. If url is provided, it's used. Otherwise
 * selects a suitable url among predefined urls based on environment value
 */
- (NSString*) endpointUrl;


@end

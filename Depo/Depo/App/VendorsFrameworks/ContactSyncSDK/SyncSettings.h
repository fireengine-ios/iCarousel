//
//  SyncSettings.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

typedef NS_ENUM(NSUInteger, SYNCEnvironment) {
    SYNCDevelopmentEnvironment,
    SYNCTestEnvironment,
    SYNCProductionEnvironment
};
typedef NS_ENUM(NSUInteger, SYNCMode) {
    SYNCBackup,
    SYNCRestore
};
typedef NS_ENUM(NSUInteger, SYNCPeriodic) {
    SYNCNone,
    SYNCDaily,
    SYNCEvery7,
    SYNCEvery30
};
typedef NS_ENUM(NSUInteger, SYNCType) {
    SYNCRequested,
    SYNCPeriod
};

@interface SyncSettings : NSObject

/**
 * Setting this value true activates debug behavior. This value
 * always should be false in production versions.
 */
@property BOOL debug;

/**
 * Setting this value true activates dry-run for duplicate analyzing.
 */
@property BOOL dryRun;

/**
 * Custom url for endpoint
 */
@property (nonatomic) NSString *url;
@property SYNCEnvironment environment;
/**
 * Sync mode. It has possible two value: BACKUP and RESTORE
 */
@property (nonatomic) SYNCMode mode;
/**
 * Sync type. It has possible two value: REQUESTED and PERIODIC
 */
@property (nonatomic) SYNCType type;
/**
 * Auth token.
 */
@property (nonatomic) NSString *token;
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
 * Backup periodically. Period is defined by this parameter
 */
@property (nonatomic) SYNCPeriodic periodicBackup;

@property NSString* countryCode;

@property NSInteger bulk;

@property (nonatomic) NSString* DEPO_URL;

@property (nonatomic, copy) void (^callback)(id data);

@property (nonatomic, copy) void (^progressCallback)();

@property (nonatomic, copy) void (^analyzeNotifyCallback)(NSMutableDictionary<NSString*, NSNumber*>*, NSMutableArray<NSString*>*);

@property (nonatomic, copy) void (^analyzeCompleteCallback)();

@property (nonatomic, copy) void (^analyzeProgressCallback)();

+ (SYNC_INSTANCETYPE) shared;

/**
 * Returns endpoint url for synchronization server. If url is provided, it's used. Otherwise
 * selects a suitable url among predefined urls based on environment value
 */
- (NSString*) endpointUrl;

- (NSString*) periodToString:(SYNCPeriodic)periodic;

@end

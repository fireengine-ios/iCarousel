//
//  ContactSyncSDK.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SyncSettings.h"
#import "SyncDB.h"
#import "SyncDBUtils.h"
#import "SyncAdapter.h"
#import "SyncStatus.h"
#import "AnalyzeStatus.h"
#import "Utils.h"
#import "BackupHelper.h"
#import "RestoreHelper.h"
#import "DepoAdapter.h"

@interface ContactSyncSDK : NSObject

/**
 * @return Last successful synchronization time
 */
+ (NSNumber*)lastSyncTime;

/**
 * Starts either backup or restore process
 */
+ (void)doSync:(SYNCMode)mode;

/**
 * Starts analyze process for duplicates
 */
+ (void)doAnalyze:(BOOL)dryRun;

/**
 * Cancels analyzing duplicate process, must be called if dry-run activated and user cancels process
 * @see SyncSettings#setDryRun(BOOL)
 * @see [SyncSettings shared].analyzeNotifyCallback
 * @see [SyncSettings shared].analyzeNotifyCallback(NSMutableDict, NSMutableArray)
 */
+ (void) cancelAnalyze;

/**
 * Continues analyzing duplicate process when dry-run activated and user continues process
 * @see SyncSettings#setDryRun(BOOL)
 * @see [SyncSettings shared].analyzeNotifyCallback
 * @see [SyncSettings shared].analyzeNotifyCallback(NSMutableDict, NSMutableArray)
 */
+ (void) continueAnalyze;

/**
 * @return Last successful periodic synchronization time
 */
+ (NSDate*)lastPeriodicSyncTime;

/**
 * Starts either backup or restore process
 */
+ (void)doPeriodicSync;

/**
 *
 * @return true, if synchronization is still running
 */
+ (BOOL)isRunning;

+ (void)hasContactForBackup:(void(^)(SYNCResultType))callback;

+ (void)getBackupStatus:(void (^)(id))callback;
#pragma mark -

@end


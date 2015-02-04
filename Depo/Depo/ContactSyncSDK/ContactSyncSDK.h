//
//  ContactSyncSDK.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SyncSettings.h"
#import "SyncDB.h"
#import "SyncDBUtils.h"
#import "SyncAdapter.h"
#import "SyncStatus.h"

@interface ContactSyncSDK : NSObject

/**
 * @return Last successful synchronization time
 */
+ (NSNumber*)lastSyncTime;

/**
 * Starts synchronization operation for one time
 */
+ (void)doSync;
/**
 * Starts synchronization process.
 * @param periodic If true, application will synchronize periodically. Otherwise it will be executed only once. Synchronization interval can be adjusted using syncInterval in SyncSettings class.
 */
+ (void)doSync:(BOOL)periodic;
/**
 * Cancels synchronization timer. Ongoing operation won't be interrupted
 */
+ (void)cancel;
/**
 * @return YES, if has automated synchronization
 */
+ (BOOL) automated;
#pragma mark Background mode operations
/**
 * Can be called in performFetchWithCompletionHandler of UIApplicationDelegate
 */
+ (void)runInBackground;
/**
 * Puts auto synchronization on hold. Can be called when application enters background.
 */
+ (void)sleep;
/**
 * Awake auto synchronization if it's enabled before. Can be called when application enters foreground.
 */
+ (void)awake;
#pragma mark -

@end

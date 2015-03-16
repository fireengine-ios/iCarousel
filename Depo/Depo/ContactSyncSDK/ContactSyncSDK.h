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
 *
 * @return true, if synchronization is still running
 */
+ (BOOL)isRunning;
#pragma mark -

@end

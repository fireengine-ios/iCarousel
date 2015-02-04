//
//  SyncStatus.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

typedef NS_ENUM(NSUInteger, SYNCResultType) {
    SYNC_RESULT_INITIAL,
    SYNC_RESULT_SUCCESS,
    SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK,
    SYNC_RESULT_ERROR_REMOTE_SERVER,
    SYNC_RESULT_ERROR_NETWORK,
    SYNC_RESULT_ERROR_INTERNAL
};

@interface SyncStatus : NSObject

@property NSInteger newContactsReceived;
@property NSInteger updatedContactsReceived;
@property NSInteger newContactsSent;
@property NSInteger updatedContactsSent;

@property NSInteger deletedContactsOnDevice;
@property NSInteger deletedContactsOnServer;

@property SYNCResultType status;
@property (strong) NSError *lastError;

+ (SYNC_INSTANCETYPE) shared;
+ (void)handleNSError:(NSError*)error;
- (void)reset;

@end

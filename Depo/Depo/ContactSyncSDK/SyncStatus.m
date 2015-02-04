//
//  SyncStatus.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "SyncStatus.h"

@implementation SyncStatus

+ (void)handleNSError:(NSError*)error
{
    SyncStatus *obj = [SyncStatus shared];
    if (!SYNC_IS_NULL(error)){
        if (!SYNC_IS_NULL(error.domain)){
            if ([NSURLErrorDomain isEqualToString:error.domain]){
                obj.status = SYNC_RESULT_ERROR_NETWORK;
            } else {
                obj.status = SYNC_RESULT_ERROR_INTERNAL;
            }
        }
        
        obj.lastError = error;
    }
}

- (void)reset
{
    _newContactsReceived = 0;
    _updatedContactsReceived = 0;
    _newContactsSent = 0;
    _updatedContactsSent = 0;
    
    _deletedContactsOnDevice = 0;
    _deletedContactsOnServer = 0;
    
    _status = SYNC_RESULT_INITIAL;
    _lastError = nil;
}

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        SyncStatus *obj = [self new];
        instance = obj;
    });
    
    return instance;
}

@end

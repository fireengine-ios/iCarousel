//
//  SyncStatus.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncStatus.h"

@implementation SyncInfo

- (instancetype)initWithContact:(Contact*)contact andState:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _localId = contact.objectId;
        _remoteId = contact.remoteId;
        _name = [contact generateDisplayName];
        _state = state;
    }
    return self;
}

- (instancetype)initWithRecord:(SyncRecord*)record andState:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _localId = record.localId;
        _remoteId = record.remoteId;
        _state = state;
    }
    return self;
}

- (instancetype)initWithEmpty:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _state = state;
    }
    return self;
}


@end

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

- (void)addContact:(Contact*)contact state:(SYNCInfoStateType)state
{
    SyncInfo *info = [[SyncInfo alloc] initWithContact:contact andState:state];
    [self addItem:info];
}
- (void)addRecord:(SyncRecord*)record state:(SYNCInfoStateType)state
{
    SyncInfo *info = [[SyncInfo alloc] initWithRecord:record andState:state];
    [self addItem:info];
}
-(void)addEmpty:(NSNumber *)count state:(SYNCInfoStateType)state{
    for(int i=0; i<[count integerValue]; i++){
        SyncInfo *info = [[SyncInfo alloc] initWithEmpty:state];
        [self addItem:info];
    }
}
- (void)addItem:(SyncInfo*)object
{
    switch (object.state) {
        case SYNC_INFO_DELETED_ON_DEVICE:
           [_deletedContactsOnDevice addObject:object];
            break;
        case SYNC_INFO_DELETED_ON_SERVER:
            [_deletedContactsOnServer addObject:object];
            break;
        case SYNC_INFO_NEW_CONTACT_ON_DEVICE:
            [_createdContactsReceived addObject:object];
            break;
        case SYNC_INFO_NEW_CONTACT_ON_SERVER:
            [_createdContactsSent addObject:object];
            break;
        case SYNC_INFO_UPDATED_ON_DEVICE:
            [_updatedContactsReceived addObject:object];
            break;
        case SYNC_INFO_UPDATED_ON_SERVER:
            [_updatedContactsSent addObject:object];
            break;
    }
}

- (void)reset
{
    _createdContactsReceived = [NSMutableArray new];
    _updatedContactsReceived = [NSMutableArray new];
    _createdContactsSent = [NSMutableArray new];
    _updatedContactsSent = [NSMutableArray new];
    
    _deletedContactsOnDevice = [NSMutableArray new];
    _deletedContactsOnServer = [NSMutableArray new];
    
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

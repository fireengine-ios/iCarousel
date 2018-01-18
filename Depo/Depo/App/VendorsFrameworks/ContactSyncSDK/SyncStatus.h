//
//  SyncStatus.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "Contact.h"
#import "SyncRecord.h"

typedef NS_ENUM(NSUInteger, SYNCResultType) {
    SYNC_RESULT_INITIAL,
    SYNC_RESULT_SUCCESS,
    SYNC_RESULT_FAIL,
    SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK,
    SYNC_RESULT_ERROR_REMOTE_SERVER,
    SYNC_RESULT_ERROR_NETWORK,
    SYNC_RESULT_ERROR_INTERNAL
};

typedef NS_ENUM(NSUInteger, SYNCInfoStateType) {
    SYNC_INFO_NEW_CONTACT_ON_DEVICE,
    SYNC_INFO_NEW_CONTACT_ON_SERVER,
    SYNC_INFO_UPDATED_ON_DEVICE,
    SYNC_INFO_UPDATED_ON_SERVER,
    SYNC_INFO_DELETED_ON_DEVICE,
    SYNC_INFO_DELETED_ON_SERVER
};

typedef NS_ENUM(NSUInteger, SYNCStep) {
    SYNC_STEP_INITIAL = 0,
    SYNC_STEP_CHECK_SERVER_STATUS = 1,
    SYNC_STEP_READ_LOCAL_CONTACTS = 2,
    SYNC_STEP_SERVER_IN_PROGRESS = 3,
    SYNC_STEP_PROCESSING_RESPONSE = 4,
};

@interface SyncInfo : NSObject

@property SYNCInfoStateType state;
@property (strong) NSString *name;
@property (strong) NSNumber *localId;
@property (strong) NSNumber *remoteId;

- (instancetype)initWithContact:(Contact*)contact andState:(SYNCInfoStateType)state;
- (instancetype)initWithRecord:(SyncRecord*)record andState:(SYNCInfoStateType)state;

@end

@interface SyncStatus : NSObject

@property (strong) NSMutableArray *createdContactsReceived;
@property (strong) NSMutableArray *updatedContactsReceived;
@property (strong) NSMutableArray *createdContactsSent;
@property (strong) NSMutableArray *updatedContactsSent;

@property (strong) NSMutableArray *deletedContactsOnDevice;
@property (strong) NSMutableArray *deletedContactsOnServer;

@property (strong) NSNumber *totalContactOnServer;
@property (strong) NSNumber *totalContactOnClient;

@property SYNCResultType status;
@property (strong) NSError *lastError;

@property SYNCStep step;
@property NSNumber *progress;

+ (SYNC_INSTANCETYPE) shared;
+ (void)handleNSError:(NSError*)error;
- (void)reset;

- (void)addContact:(Contact*)contact state:(SYNCInfoStateType)state;
- (void)addRecord:(SyncRecord*)record state:(SYNCInfoStateType)state;
- (void)addEmpty:(NSNumber *)count state:(SYNCInfoStateType)state;
- (NSString*)resultTypeToString:(SYNCResultType) type;


@end

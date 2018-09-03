//
//  ApiAdapter.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GET,
    POST,
    PUT,
    DELETE,
    PATCH
} HttpMethod;

@interface SyncAdapter : NSObject

+ (void)getLastBackup:(void (^)(id, BOOL))callback;
+ (void)getContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)getUpdatedContacts:(NSNumber *)lastSyncTime deviceId:(NSString *)deviceId callback:(void (^)(id, BOOL))callback;
+ (void)backupContactsWithDeviceId:(NSString *)deviceId dirtyContacts:(NSArray*)dirtyContacts deletedContacts:(NSArray *)deletedContacts callback:(void (^)(id, BOOL))callback;
+ (void)restoreContactsWithTimestamp:(long long)timestamp deviceId:(NSString *)deviceId modifiedContactIDs:(NSArray *)modifiedContactIDs newContacts:(NSArray *)newContacts callback:(void(^)(id, BOOL))callback;
+ (void)deleteContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)deleteContact:(NSNumber*)contactId permanent:(BOOL)permanent callback:(void (^)(id, BOOL))callback;
+ (void)getServerTime:(void (^)(id, BOOL))callback;
+ (void)checkStatus:(NSString*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)sendStats:(NSString*)key start:(NSInteger)start result:(NSInteger)result created:(NSInteger)created updated:(NSInteger)updated deleted:(NSInteger)deleted status:(NSInteger)status errorCode:(NSString*)errorCode errorMsg:(NSString*)errorMsg;
+ (void)sendStats:(NSString*)key start:(NSInteger)start result:(NSInteger)result created:(NSInteger)created updated:(NSInteger)updated deleted:(NSInteger)deleted status:(NSInteger)status errorCode:(NSString*)errorCode errorMsg:(NSString*)errorMsg operation:(NSString*)operation;

+ (void)sendLog:(NSData*)data file:(NSString*)file;

@end

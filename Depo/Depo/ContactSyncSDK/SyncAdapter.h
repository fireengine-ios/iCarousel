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

+ (void)getContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)getContacts:(void (^)(id, BOOL))callback;
+ (void)updateContacts:(NSArray*)contacts callback:(void (^)(id, BOOL))callback;
+ (void)deleteContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)deleteContact:(NSNumber*)contactId permanent:(BOOL)permanent callback:(void (^)(id, BOOL))callback;
+ (void)getServerTime:(void (^)(id, BOOL))callback;
+ (void)checkStatus:(NSString*)contactId callback:(void (^)(id, BOOL))callback;

@end

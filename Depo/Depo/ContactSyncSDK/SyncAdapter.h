//
//  ApiAdapter.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
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
+ (void)getContacts:(NSNumber*)currentPage pageSize:(NSNumber*)pageSize totalRecords:(NSNumber*)totalRecords callback:(void (^)(id, BOOL))callback;
+ (void)updateContacts:(NSArray*)contacts callback:(void (^)(id, BOOL))callback;
+ (void)deleteContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback;
+ (void)getServerTime:(void (^)(id, BOOL))callback;

@end

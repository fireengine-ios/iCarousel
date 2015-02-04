//
//  SyncSettings.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "SyncSettings.h"

@interface SyncSettings ()

@end

@implementation SyncSettings


#define CONTACT_SYNC_BASE_DEV_URL @"http://127.0.0.1:8002/sync/ttyapi/";
#define CONTACT_SYNC_BASE_TEST_URL @"http://contactsync.test.valven.com/ttyapi/";
#define CONTACT_SYNC_BASE_PROD_URL @"";

- (instancetype)init
{
    self = [super init];
    if (self){
        _debug = YES;
        _environment = SYNCDevelopmentEnvironment;
        _syncInterval = SYNC_DEFAULT_INTERVAL*60;
    }
    return self;
}

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        SyncSettings *obj = [self new];
        instance = obj;
    });
    
    return instance;
}

- (NSString*)endpointUrl
{
    if (self.url){
        return self.url;
    }
    switch (self.environment) {
        case SYNCProductionEnvironment:
            return CONTACT_SYNC_BASE_PROD_URL;
        case SYNCTestEnvironment:
            return CONTACT_SYNC_BASE_TEST_URL;
        default:
            return CONTACT_SYNC_BASE_DEV_URL;
    }
}



@end

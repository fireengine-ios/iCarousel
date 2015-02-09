//
//  SyncSettings.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncSettings.h"

@interface SyncSettings ()

@end

@implementation SyncSettings

@synthesize periodicSync = _periodicSync;

#define CONTACT_SYNC_BASE_DEV_URL @"http://127.0.0.1:8002/sync/ttyapi/";
#define CONTACT_SYNC_BASE_TEST_URL @"http://contactsync.test.valven.com/ttyapi/";
#define CONTACT_SYNC_BASE_PROD_URL @"";

- (instancetype)init
{
    self = [super init];
    if (self){
        _debug = YES;
        _environment = SYNCDevelopmentEnvironment;
        _syncInterval = SYNC_DEFAULT_INTERVAL;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *automated = [defaults objectForKey:SYNC_KEY_AUTOMATED];
        if (SYNC_IS_NULL(automated) || ![automated boolValue]){
            _periodicSync = NO;
        } else {
            _periodicSync = YES;
        }
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

- (void)setPeriodicSync:(BOOL)periodicSync
{
    _periodicSync = periodicSync;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:periodicSync] forKey:SYNC_KEY_AUTOMATED];
    [defaults synchronize];
    
}

- (BOOL)getPeriodicSync
{
    return _periodicSync;
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

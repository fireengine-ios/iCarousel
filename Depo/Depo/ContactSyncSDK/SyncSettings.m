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
@synthesize delayInterval = _delayInterval;

#define CONTACT_SYNC_BASE_DEV_URL @"http://127.0.0.1:8002/sync/ttyapi/";
#define CONTACT_SYNC_BASE_TEST_URL @"https://tcloudstb.turkcell.com.tr/ttyapi/";
#define CONTACT_SYNC_BASE_PROD_URL @"https://adepo.turkcell.com.tr/ttyapi/";

- (instancetype)init
{
    self = [super init];
    if (self){
        _debug = YES;
        _environment = SYNCDevelopmentEnvironment;
        _syncInterval = SYNC_DEFAULT_INTERVAL;
        _delayInterval = SYNC_DEFAULT_DELAY;
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
-(void)setDelayInterval:(NSTimeInterval)delayInterval{
    _delayInterval=delayInterval;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithDouble:delayInterval] forKey:SYNC_KEY_DELAY];
    [defaults synchronize];
    
}
-(NSTimeInterval)delayInterval {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:SYNC_KEY_DELAY]?[[defaults valueForKey:SYNC_KEY_DELAY] doubleValue]:SYNC_DEFAULT_DELAY;
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

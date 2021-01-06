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

@synthesize periodicBackup = _periodicBackup;
@synthesize delayInterval = _delayInterval;
@synthesize url = _url;
@synthesize token = _token;

#define CONTACT_SYNC_BASE_DEV_URL @"http://contactsync.test.valven.com/ttyapi/";
#define CONTACT_SYNC_BASE_TEST_URL @"https://contactsynctest.turkcell.com.tr/ttyapi/";
#define CONTACT_SYNC_BASE_PROD_URL @"https://contactsync.turkcell.com.tr/ttyapi/";

- (instancetype)init
{
    self = [super init];
    if (self){
        _debug = YES;
        _dryRun = YES;
        _environment = SYNCTestEnvironment;
        _syncInterval = SYNC_DEFAULT_INTERVAL;
        _delayInterval = SYNC_DEFAULT_DELAY;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSNumber *periodicBackup = [defaults objectForKey:SYNC_KEY_PERIODIC_OPTION];
        if (SYNC_IS_NULL(periodicBackup)){
            _periodicBackup = SYNCNone;
        }
        else {
            _periodicBackup = (SYNCPeriodic)[periodicBackup integerValue];
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

- (void)setPeriodicBackup:(SYNCPeriodic)periodicBackup
{
    _periodicBackup = periodicBackup;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (periodicBackup){
        [defaults setObject:@(periodicBackup) forKey:SYNC_KEY_PERIODIC_OPTION];
    }
    else {
        [defaults setObject:@(SYNCNone) forKey:SYNC_KEY_PERIODIC_OPTION];
    }
    [defaults synchronize];

}

- (SYNCPeriodic)getPeriodicBackup
{
    return _periodicBackup;
}

-(void)setDEPO_URL:(NSString *)DEPO_URL {
    _DEPO_URL = DEPO_URL;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[self endpointUrl] forKey:SYNC_KEY_DEPO_URL];
    [defaults synchronize];
}

-(void)setUrl:(NSString *)url{
    _url = url;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[self endpointUrl] forKey:SYNC_KEY_PERIODIC_URL];
    [defaults synchronize];
}

-(void)setToken:(NSString *)token{
    _token = token;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:SYNC_KEY_PERIODIC_TOKEN];
    [defaults synchronize];
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

- (NSString*) periodToString:(SYNCPeriodic)periodic {
    NSString *result = @"";
    switch (periodic) {
        case SYNCDaily:
            result = @"Daily";
            break;
        case SYNCEvery7:
            result = @"Weekly";
            break;
        case SYNCEvery30:
            result = @"Monthly";
            break;
        default:
            result = @"None";
            break;
    }
    return result;
}

@end

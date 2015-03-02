//
//  CurioSDK.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 16/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@interface CurioScreenData : NSObject

@property (nonatomic,strong) NSString *className;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *path;

@end

@implementation CurioScreenData

- (id) init {
    self = [super init];
    
    return  self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:CURKeyScreenDataTitle];
        self.className = [decoder decodeObjectForKey:CURKeyScreenDataClassName];
        self.path = [decoder decodeObjectForKey:CURKeyScreenDataPath];
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:CURKeyScreenDataTitle];
    [encoder encodeObject:_className forKey:CURKeyScreenDataClassName];
    [encoder encodeObject:_path forKey:CURKeyScreenDataPath];
}

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[CurioScreenData class]]) {
        return NO;
    }
    
    CurioScreenData *o = object;

    return [self.title isEqualToString:o.title] &&
        [self.className isEqualToString:o.className] &&
    [self.path isEqualToString:o.path];
}

- (NSUInteger)hash {
    return [self.title hash] ^ [self.className hash] ^ [self.path hash];
}

@end

@implementation CurioSDK


+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id) init {
    if ((self = [super init])) {
        
        appWasInBackground = FALSE;
        
        _aliveScreens = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillGoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationGotActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
        _sessionCodeRegisteredOnServer = FALSE;
        
        curioQueue = [NSOperationQueue new];
        [curioQueue setMaxConcurrentOperationCount:1];

        
        curioActionQueue = [NSOperationQueue new];
        [curioActionQueue setMaxConcurrentOperationCount:1];

        _memoryStore = [NSMutableDictionary new];
        

        // Invoke settings initialization
        [CurioSettings shared];

        // Invoke network initialization
        [CurioNetwork shared];
        
        // Invoke post office initialization
        [CurioPostOffice shared];
        
        CS_Log_Info(@"\r\rValues fetched from bundle:\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r%@ = %@\r\r",
                    CS_OPT_SKEY_SERVER_URL, [[CurioSettings shared] serverUrl],
                    CS_OPT_SKEY_API_KEY, [[CurioSettings shared] apiKey],
                    CS_OPT_SKEY_TRACKING_CODE, [[CurioSettings shared] trackingCode],
                    CS_OPT_SKEY_SESSION_TIMEOUT, [[CurioSettings shared] sessionTimeout],
                    CS_OPT_SKEY_PERIODIC_DISPATCH_ENABLED, [[CurioSettings shared] periodicDispatchEnabled],
                    CS_OPT_SKEY_DISPATCH_PERIOD, [[CurioSettings shared] dispatchPeriod],
                    CS_OPT_SKEY_MAX_CACHED_ACTIVITY_COUNT, [[CurioSettings shared] maxCachedActivityCount],
                    CS_OPT_SKEY_LOGGING_ENABLED, [[CurioSettings shared] loggingEnabled],
                    CS_OPT_SKEY_LOGGING_LEVEL, [[CurioSettings shared] logLevel],
                    CS_OPT_SKEY_REGISTER_FOR_REMOTE_NOTIFICATIONS, [[CurioSettings shared] registerForRemoteNotifications],
                    CS_OPT_SKEY_NOTIFICATION_TYPES, [[CurioSettings shared] notificationTypes],
                    CS_OPT_SKEY_FETCH_LOCATION_ENABLED, [[CurioSettings shared] fetchLocationEnabled],
                    CS_OPT_SKEY_MAX_VALID_LOCATION_TIME_INTERVAL, [[CurioSettings shared] maxValidLocationTimeInterval]
                    
          );

        
        
        
    }
    return self;
}

#pragma mark Application handling

- (void) finishOffOpenScreens {
    
    
    NSMutableArray *dup = [_aliveScreens copy];

   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_aliveScreens] forKey:CS_CONST_AL_SC];
    [userDefaults synchronize];
    
    [dup enumerateObjectsUsingBlock:^(CurioScreenData *obj, NSUInteger idx, BOOL *stop) {
        
        [self endScreenWithClassName:obj.className];

    }];
    
    [_aliveScreens removeAllObjects];
    

}

- (void) enterDeactiveMode {

    [curioActionQueue waitUntilAllOperationsAreFinished];

    [curioQueue cancelAllOperations];
    
    
    appWasInBackground = TRUE;
    
    __block UIBackgroundTaskIdentifier ti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [[CurioPostOffice shared] tryToPostAwaitingActions:TRUE];

        [[UIApplication sharedApplication] endBackgroundTask:ti];
        
    }];
    
}

- (void) applicationWillGoBackground {

    // Uniquize screens
    [_aliveScreens setArray:[[NSSet setWithArray:_aliveScreens] allObjects]];
    
    CS_Log_Info(@"Finishing off %lu",(unsigned long)_aliveScreens.count);
    
    [self finishOffOpenScreens];
    
    [self enterDeactiveMode];

    
}

- (void) applicationWillTerminate {

    [self endSession];
    
    [self enterDeactiveMode];
    
}

- (void) applicationGotActive {

    
    
    if (appWasInBackground) {
        
        CS_Log_Info(@"Restoring back previous states");

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        NSData *dat = [userDefaults objectForKey:CS_CONST_AL_SC];
        
        
        if (dat == nil)
            _aliveScreens = [NSMutableArray new];
        else {
            _aliveScreens = [NSKeyedUnarchiver unarchiveObjectWithData:dat];
            CS_Log_Info(@"Restoring %lu screens",(unsigned long)_aliveScreens.count);
            [_aliveScreens enumerateObjectsUsingBlock:^(CurioScreenData *obj, NSUInteger idx, BOOL *stop) {
                [self startScreenWithName:obj.className title:obj.title path:obj.path];
            }];
        }
        
        [userDefaults removeObjectForKey:CS_CONST_AL_SC];
        [userDefaults synchronize];
    }
    
}

- (void) reGenerateSessionCode {
        [_memoryStore setObject:[[CurioUtil shared] uuidV1] forKey:CURKeySessionCode];
}


- (NSString *) sessionCode {
    
    NSString *ret = [_memoryStore objectForKey:CURKeySessionCode];
    
    if (ret == nil) {
        
        ret = [[CurioUtil shared] uuidV1];
        
        [_memoryStore setObject:ret forKey:CURKeySessionCode];
        
    }
    
    return ret;
    
}

- (void) sendEvent:(NSString *) eventKey eventValue:(NSString *) eventValue {

    [curioActionQueue addOperationWithBlock:^{

        CurioAction *actionSendEvent = [CurioAction actionSendEvent:eventKey path:eventValue];
    
        [[CurioDBToolkit shared] addAction:actionSendEvent];
    }];

}

- (void) endScreenWithClassName:(NSString *) screenClassName  {
    
    [curioActionQueue addOperationWithBlock:^{
        
        NSString *key = [NSString stringWithFormat:@"HC%@",screenClassName];
        
        NSString *hitcode = [_memoryStore objectForKey:key];
        
        CurioAction *actionEndScreen = [CurioAction actionEndScreen:hitcode == nil ? @"UNKNOWN" : hitcode];
        
        [[CurioDBToolkit shared] addAction:actionEndScreen];
        
        [_memoryStore removeObjectForKey:key];
        
        
        __block int rmIndex = -1;
        [_aliveScreens enumerateObjectsUsingBlock:^(CurioScreenData *obj, NSUInteger idx, BOOL *stop) {
           
            if ([obj.className isEqualToString:screenClassName])
            {
                rmIndex = (int)idx;
                *stop = true;
            }
        }];
        
        if (rmIndex != -1)
            [_aliveScreens removeObjectAtIndex:rmIndex];
        
    }];
}

- (void) endScreen:(Class) screenClass  {
    [self endScreenWithClassName:(NSStringFromClass(screenClass))];
}

- (void) startScreenWithName:(NSString *) screenClassName title:(NSString *) title path:(NSString *) path {

    [curioActionQueue addOperationWithBlock:^{
        CurioAction *actionStartScreen = [CurioAction actionStartScreen:title path:path];
        
        [actionStartScreen.properties setObject:screenClassName forKey:CS_CUSTOM_VAR_SCREENCLASS];
        
        if (![[CurioNetwork shared] isOnline] || CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
            
            NSString *hitCode = [[CurioUtil shared] uuidRandom];
            
            [_memoryStore setObject:hitCode forKey:[NSString stringWithFormat:@"HC%@",screenClassName]];
            actionStartScreen.hitCode = hitCode;
        }
        
        [[CurioDBToolkit shared] addAction:actionStartScreen];
        
        CurioScreenData *csd = [CurioScreenData new];
        csd.title = title;
        csd.path = path;
        csd.className = screenClassName;
        
        [_aliveScreens addObject:csd];
        
    }];

}


- (void) startScreen:(Class) screenClass title:(NSString *) title path:(NSString *) path {

    [self startScreenWithName:NSStringFromClass(screenClass) title:title path:path];
    
}


- (void) endSession {
    
    [curioActionQueue addOperationWithBlock:^{
        CurioAction *actionEndSession = [CurioAction actionEndSession];
        
        [_memoryStore removeObjectForKey:CURKeySessionCode];
        
        [[CurioDBToolkit shared] addAction:actionEndSession];
    }];
    
    [curioQueue addOperationWithBlock:^{
        
        [curioActionQueue waitUntilAllOperationsAreFinished];
        
        // No matter we are in PDR or not, start session and end session
        // request should be send immediately if possible
        [[CurioPostOffice shared] tryToPostAwaitingActions:NO];
    }];
}

- (void) startSession:(NSString *)serverUrl
               apiKey:(NSString *)apiKey
         trackingCode:(NSString *)trackingCode
     appLaunchOptions:(NSDictionary *)appLaunchOptions
{
    
    [[CurioSettings shared] set:serverUrl apiKey:apiKey trackingCode:trackingCode];
    [self startSession:appLaunchOptions];
}


- (void) startSession:(NSString *)serverUrl
               apiKey:(NSString *)apiKey
         trackingCode:(NSString *)trackingCode
       sessionTimeout:(int)sessionTimeout
periodicDispatchEnabled:(BOOL)periodicDispatchEnabled
       dispatchPeriod:(int)dispatchPeriod
maxCachedActivitiyCount:(int)maxCachedActivityCount
       loggingEnabled:(BOOL)logginEnabled
             logLevel:(int)logLevel
registerForRemoteNotifications:(BOOL)registerForRemoteNotifications
    notificationTypes:(NSString *) notificationTypes
 fetchLocationEnabled:(BOOL)fetchLocationEnabled
maxValidLocationTimeInterval:(double)maxValidLocationTimeInterval
     appLaunchOptions:(NSDictionary *)appLaunchOptions
{
    
  
    
    [[CurioSettings shared] set:serverUrl
                         apiKey:apiKey
                   trackingCode:trackingCode
                 sessionTimeout:[NSNumber numberWithInt:sessionTimeout]
        periodicDispatchEnabled:periodicDispatchEnabled ? CS_NSN_TRUE :   CS_NSN_FALSE
                 dispatchPeriod:[NSNumber numberWithInt:dispatchPeriod]
        maxCachedActivitiyCount:[NSNumber numberWithInt:maxCachedActivityCount]
                 loggingEnabled:logginEnabled ? CS_NSN_TRUE : CS_NSN_FALSE
                       logLevel:[NSNumber numberWithInt:logLevel]
 registerForRemoteNotifications:registerForRemoteNotifications ? CS_NSN_TRUE : CS_NSN_FALSE
              notificationTypes:notificationTypes
           fetchLocationEnabled:fetchLocationEnabled ? CS_NSN_TRUE : CS_NSN_FALSE
        maxValidLocationTimeInterval:[NSNumber numberWithDouble:maxValidLocationTimeInterval]
     ];
    [self startSession:appLaunchOptions];

}

- (void) startSession:(NSDictionary *) appLaunchOptions {
    
    
    _appLaunchOptions = appLaunchOptions != nil ? appLaunchOptions : [NSDictionary new];
    
    [curioActionQueue addOperationWithBlock:^{
        
        CurioAction *actionStartSession = [CurioAction actionStartSession];
        
        CS_Log_Info(@"Start Session action: %@",CS_RM_STR_NEWLINE(actionStartSession.asDict));
        
        [[CurioDBToolkit shared] addAction:actionStartSession];
        
        if (CS_NSN_IS_TRUE([[CurioSettings shared] registerForRemoteNotifications]))
            [[CurioNotificationManager shared] registerForNotifications];
                
        if (CS_NSN_IS_TRUE([[CurioSettings shared] fetchLocationEnabled]))
            [[CurioLocationManager shared] sendLocation];
        
    }];
    
    [curioQueue addOperationWithBlock:^{
        
        [curioActionQueue waitUntilAllOperationsAreFinished];
        
        // No matter we are in PDR or not, start session and end session
        // request should be send immediately if possible
        [[CurioPostOffice shared] tryToPostAwaitingActions:NO];
        
    }];
}


- (void) unregisterFromNotificationServer{
    [[CurioNotificationManager shared] unregister];
}

- (void) sendCustomId:(NSString *)theCustomId{
    CS_Log_Debug(@"Sending custom id: %@",theCustomId);
    [self setCustomId:theCustomId];
    [[CurioNotificationManager shared] sendPushData:nil];
}
    
- (void) sendLocation{
    [[CurioLocationManager shared] sendLocation];
}

- (void)getNotificationHistoryWithPageStart:(NSInteger)pageStart
                                       rows:(NSInteger)rows
                                 success:(void(^)(NSDictionary *responseObject))success
                                 failure:(void(^)(NSError *error))failure {
    
    if (![[CurioSDK shared] sessionCodeRegisteredOnServer]) {
        NSError *error = [[NSError alloc] initWithDomain:@"Curio SDK" code:-1 userInfo:@{@"error": @"Session code has not yet been registered on remote."}];
        failure(error);
        return;
    } else if ([[CurioNotificationManager shared] deviceToken] == nil) {
        NSError *error = [[NSError alloc] initWithDomain:@"Curio SDK" code:-1 userInfo:@{@"error": @"Device token can not be nil."}];
        failure(error);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode,
                                    [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode,
                                    [[CurioNotificationManager shared] deviceToken], CURHttpParamPushToken,
                                    [[CurioSDK shared] sessionCode], CURKeySessionCode,
                                    nil];
        
        NSString *suffix = [NSString stringWithFormat:@"%@/%ld/%ld", CS_SERVER_URL_SUFFIX_PUSH_HISTORY, (long)pageStart, (long)rows];
        
        [[CurioPostOffice shared] postRequestWithParameters:parameters suffix:suffix success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
                
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
                
            });
        }];
    });
}

@end

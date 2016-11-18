//
//  CurioSDK.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 16/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@interface CurioEventData : NSObject

@property (nonatomic,strong) NSString *eventKey;
@property (nonatomic,strong) NSString *eventValue;
@property (nonatomic,strong) NSString *eventDuration;

@end

@implementation CurioEventData

- (id) init {
    self = [super init];
    
    return  self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.eventKey = [decoder decodeObjectForKey:CURKeyEventKey];
        self.eventValue = [decoder decodeObjectForKey:CURKeyEventValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_eventKey forKey:CURKeyEventKey];
    [encoder encodeObject:_eventValue forKey:CURKeyEventValue];
}

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[CurioEventData class]]) {
        return NO;
    }
    
    CurioEventData *o = object;
    
    return [self.eventKey isEqualToString:o.eventKey] && [self.eventValue isEqualToString:o.eventValue];
}

- (NSUInteger)hash {
    return [self.eventKey hash] ^ [self.eventValue hash];
}

@end

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
        
        _retryCount = 0;
        
        _aliveScreens = [NSMutableArray new];
        _aliveEvents = [NSMutableArray new];
        
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
        
        if([CurioSettings shared].sessionTimeout < [CurioSettings shared].dispatchPeriod){
            CS_Log_Warning(@"Session timeout cannot be less than dispatch period. Please specify session timeout and dispatch period accordingly.");
        }

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

- (void) finishOffOpenEvents {
    
    NSMutableArray *dup = [_aliveEvents copy];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_aliveEvents] forKey:CS_CONST_AL_EV];
    [userDefaults synchronize];
    
    [dup enumerateObjectsUsingBlock:^(CurioEventData *obj, NSUInteger idx, BOOL *stop) {
        
        [self endEvent:obj.eventKey eventValue:obj.eventValue eventDuration:[obj.eventDuration integerValue]];
        
    }];
    
    [_aliveEvents removeAllObjects];
    
    
}

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
    
    CS_Log_Info(@"Finishing off alive screens count %lu",(unsigned long)_aliveScreens.count);
    
    [_aliveEvents setArray:[[NSSet setWithArray:_aliveEvents] allObjects]];
    
    CS_Log_Info(@"Finishing off alive events count %lu",(unsigned long)_aliveEvents.count);

    [self finishOffOpenScreens];
    [self finishOffOpenEvents];
    
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

        NSData *datAliveScreens = [userDefaults objectForKey:CS_CONST_AL_SC];
        
        if (datAliveScreens == nil)
            _aliveScreens = [NSMutableArray new];
        else {
            _aliveScreens = [NSKeyedUnarchiver unarchiveObjectWithData:datAliveScreens];
            CS_Log_Info(@"Restoring %lu screens",(unsigned long)_aliveScreens.count);
            [_aliveScreens enumerateObjectsUsingBlock:^(CurioScreenData *obj, NSUInteger idx, BOOL *stop) {
                [self startScreenWithName:obj.className title:obj.title path:obj.path];
            }];
        }
        
        [userDefaults removeObjectForKey:CS_CONST_AL_SC];
        [userDefaults synchronize];
        
        NSData *datAliveEvents = [userDefaults objectForKey:CS_CONST_AL_EV];
        
        if (datAliveEvents == nil)
            _aliveEvents = [NSMutableArray new];
        else {
            _aliveEvents = [NSKeyedUnarchiver unarchiveObjectWithData:datAliveEvents];
            CS_Log_Info(@"Restoring %lu events",(unsigned long)_aliveEvents.count);
            [_aliveEvents enumerateObjectsUsingBlock:^(CurioEventData *obj, NSUInteger idx, BOOL *stop) {
                [self sendEvent:obj.eventKey eventValue:obj.eventValue];
            }];
        }
        
        [userDefaults removeObjectForKey:CS_CONST_AL_EV];
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

- (void) endEvent:(NSString *) eventKey  eventValue:(NSString *) eventValue eventDuration:(NSUInteger) eventDuration {
    
    [curioActionQueue addOperationWithBlock:^{
        
        //TODO key? HC%@_HC%@?
        NSString *key = [NSString stringWithFormat:@"HC%@_%@",eventKey,eventValue];
        
        NSString *hitcode = [_memoryStore objectForKey:key];
        
        CurioAction *actionEndEvent = [CurioAction actionEndEvent:(hitcode == nil ? @"UNKNOWN" : hitcode) eventDuration:eventDuration];
        
        [[CurioDBToolkit shared] addAction:actionEndEvent];
        
        [_memoryStore removeObjectForKey:key];
        
        __block int rmIndex = -1;
        [_aliveEvents enumerateObjectsUsingBlock:^(CurioEventData *obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj.eventKey isEqualToString:eventKey] && [obj.eventValue isEqualToString:eventValue])
            {
                rmIndex = (int)idx;
                *stop = true;
            }
        }];
        
        if (rmIndex != -1)
            [_aliveEvents removeObjectAtIndex:rmIndex];
        
    }];
}

- (void) sendEvent:(NSString *) eventKey eventValue:(NSString *) eventValue {

    [curioActionQueue addOperationWithBlock:^{
        CurioAction *actionSendEvent = [CurioAction actionSendEvent:eventKey path:eventValue];
        
        [actionSendEvent.properties setObject:[NSString stringWithFormat:@"%@_%@", eventKey, eventValue] forKey:CS_CUSTOM_VAR_EVENTCLASS];
        
        if (![[CurioNetwork shared] isOnline] || CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
            
            NSString *hitCode = [[CurioUtil shared] uuidRandom];
            
            
            
            NSString *eventKeyAndValue = [actionSendEvent.properties objectForKey:CS_CUSTOM_VAR_EVENTCLASS];
            CS_Log_Info(@"Created hit code %@ for screen %@ when periodicDispatchEnabled or the client is offline.",hitCode,eventKeyAndValue);
            
            [_memoryStore setObject:hitCode forKey:[NSString stringWithFormat:@"HC%@_%@",eventKey, eventValue]];
            actionSendEvent.hitCode = hitCode;
        }
        
        [[CurioDBToolkit shared] addAction:actionSendEvent];
        
        CurioEventData *csd = [CurioEventData new];
        csd.eventKey = eventKey;
        csd.eventValue = eventValue;
        
        [_aliveEvents addObject:csd];
        
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
            NSString *screenKey = [actionStartScreen.properties objectForKey:CS_CUSTOM_VAR_SCREENCLASS];
            CS_Log_Info(@"Created hit code %@ for screen %@ when periodicDispatchEnabled or the client is offline.",hitCode,screenKey);
            
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
    
    //this is done for getting bluetoothstate
    [self performSelector:@selector(startSession:) withObject:appLaunchOptions afterDelay:0.1];
    //[self startSession:appLaunchOptions];
    
}

/*! Starts Curio session.
 * \param startSession serverUrl [Required] Curio server URL, can be obtained from Turkcell.
 * \param apiKey [Required] Application specific API key, can be obtained from Turkcell.
 * \param trackingCode [Required] Application specific tracking code, can be obtained from Turkcell.
 * \param sessionTimeout [Optional] Session timeout in minutes. Default is 30 minutes but it's highly recommended to change this value acording to the nature of your application. Specifiying a correct session timeout value for your application will increase the accuracy of the analytics data.
 * \param periodicDispatchEnabled [Optional] Periodic dispatch is enabled if true. Default is false.
 * \param dispatchPeriod [Optional] If periodic dispatch is enabled, this parameter configures dispatching period in minutes. Deafult is 5 minutes. Note: This parameter cannot be greater than session timeout value.
 * \param maxCachedActivitiyCount [Optional] Max. number of user activity that Curio library will remember when device is not connected to the Internet. Default is 1000. Max. value can be 4000.
 * \param loggingEnabled [Optional] All of the Curio logs will be disabled if this is false. Default is true.
 * \param logLevel [Optional] Contains level of the print-out logs. 0 - Error, 1 - Warning, 2 - Info, 3 - Debug. Default is 0 (Error).
 * \param registerForRemoteNotifications If enabled, then Curio SDK will automatically register for remote notifications for types defined in "NotificationTypes" parameter.
 * \param notificationTypes Notification types to register; available values: Sound, Badge, Alert
 * \param fetchLocationEnabled [Optional] If enabled, the current location of the device will be tracked while using the application. Default is true. The accuracy of recent location is validated using MaxValidLocationTimeInterval. Location tracking stops when the accurate location is found according to the needs. For further location tracking you can use [[CurioSDK shared] sendLocation] method. In order to track locations in iOS8 NSLocationWhenInUseUsageDescription must be implemented in Info.plist file.
 * \param maxValidLocationTimeInterval [Optional] Default is 600 seconds. The accuracy of recent location is validated using this parameter. Location tracking continues until it reaches to a valid location time interval.
 * \param delegate If you are using "CurioSDKDelegate" protocol, you can set this parameter with your class reference. "CurioSDKDelegate" protocol provides callbacks for responses from "unregisterFromNotificationServer" and "sendCustomId" methods.
 * \param appLaunchOptions Set this with Appdelegate's appLaunchOptions. It is used for tracking notifications.
 */
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
             delegate:(id<CurioSDKDelegate>)delegate
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
    
    self.delegate = delegate;
    
    //this is done for getting bluetoothstate
    [self performSelector:@selector(startSession:) withObject:appLaunchOptions afterDelay:0.1];
    
    //[self startSession:appLaunchOptions];
}

-(void)startSession:(NSString *)serverUrl
             apiKey:(NSString *)apiKey
       trackingCode:(NSString *)trackingCode
     sessionTimeout:(int)sessionTimeout
periodicDispatchEnabled:(BOOL)periodicDispatchEnabled
     dispatchPeriod:(int)dispatchPeriod
maxCachedActivitiyCount:(int)maxCachedActivityCount
     loggingEnabled:(BOOL)logginEnabled
           logLevel:(int)logLevel
fetchLocationEnabled:(BOOL)fetchLocationEnabled
maxValidLocationTimeInterval:(double)maxValidLocationTimeInterval
   appLaunchOptions:(NSDictionary *)appLaunchOptions {
    
    [[CurioSettings shared] set:serverUrl
                         apiKey:apiKey
                   trackingCode:trackingCode
                 sessionTimeout:[NSNumber numberWithInt:sessionTimeout]
        periodicDispatchEnabled:periodicDispatchEnabled ? CS_NSN_TRUE :   CS_NSN_FALSE
                 dispatchPeriod:[NSNumber numberWithInt:dispatchPeriod]
        maxCachedActivitiyCount:[NSNumber numberWithInt:maxCachedActivityCount]
                 loggingEnabled:logginEnabled ? CS_NSN_TRUE : CS_NSN_FALSE
                       logLevel:[NSNumber numberWithInt:logLevel]
           fetchLocationEnabled:fetchLocationEnabled ? CS_NSN_TRUE : CS_NSN_FALSE
   maxValidLocationTimeInterval:[NSNumber numberWithDouble:maxValidLocationTimeInterval]
     ];
    
    //this is done for getting bluetoothstate
    [self performSelector:@selector(startSession:) withObject:appLaunchOptions afterDelay:0.1];
    
}

- (void) startSession:(NSDictionary *) appLaunchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregisterFromNotificationServerNotified:) name:CS_NOTIF_UNREGISTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customIDSetNotified:) name:CS_NOTIF_CUSTOM_ID_SET object:nil];

    _appLaunchOptions = appLaunchOptions != nil ? appLaunchOptions : [NSDictionary new];
    
    [curioActionQueue addOperationWithBlock:^{
#if !TARGET_OS_TV
        [CurioResourceUtil shared];
#endif
        
        CurioAction *actionStartSession = [CurioAction actionStartSession];
        
        CS_Log_Info(@"Start Session action: %@",CS_RM_STR_NEWLINE(actionStartSession.asDict));
        
        [[CurioDBToolkit shared] addAction:actionStartSession];
        
#if !TARGET_OS_TV
        if (CS_NSN_IS_TRUE([[CurioSettings shared] registerForRemoteNotifications]))
            [[CurioNotificationManager shared] registerForNotifications];
#endif
        
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
    
    if ([[CurioNetwork shared] isOnline]) {
        [curioActionQueue addOperationWithBlock:^{
            CurioAction *actionUnregister = [CurioAction actionUnregister];
            
            CS_SET_DICT_IF_NOT_NIL(actionUnregister.properties, [self customId], CURHttpParamCustomId);
            
            //[actionUnregister.properties setObject:[self customId] forKey:CURHttpParamCustomId];
            
            [[CurioDBToolkit shared] addAction:actionUnregister];
        }];
        
        [curioQueue addOperationWithBlock:^{
            
            [curioActionQueue waitUntilAllOperationsAreFinished];
            
            // No matter we are in PDR or not, start session and end session
            // request should be send immediately if possible
            [[CurioPostOffice shared] tryToPostAwaitingActions:NO];
            
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_UNREGISTER
                                                            object:nil
                                                          userInfo: @{CURKeyStatus: CURKeyNOK, CURKeyResponse: @"Curio SDK is not online. Network connection may have been lost."}];
    }
}

- (void) sendCustomId:(NSString *)theCustomId{
    CS_Log_Debug(@"Sending custom id: %@",theCustomId);
    [self setCustomId:theCustomId];
    [[CurioNotificationManager shared] sendPushData:@{CURKeySendCustomID:@"YES"}];
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

#pragma mark - Unregister and CustomID set observers

- (void)unregisterFromNotificationServerNotified:(NSNotification *)notification __TVOS_UNAVAILABLE {
    __weak CurioSDK *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(unregisteredFromNotificationServer:)]) {
            [weakSelf.delegate unregisteredFromNotificationServer:notification.userInfo];
        }
    });
}

- (void)customIDSetNotified:(NSNotification *)notification __TVOS_UNAVAILABLE {
    __weak CurioSDK *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(customIDSent:)]) {
            [weakSelf.delegate customIDSent:notification.userInfo];
        }
    });
}

-(void)sendUserTags:(NSDictionary *)tags {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tags
                                                       options:0
                                                         error:&error];
    NSString *jsonString;
    if (error) {
        CS_Log_Warning(@"Creating user tags dictionary failed: %@", [error description]);
        return;
    }else {
         jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode,
                                [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode,
                                [[CurioSDK shared] sessionCode], CURKeySessionCode,
                                jsonString, CURKeyUserTags,
                                nil];
        
        [[CurioPostOffice shared] postRequestResultWithParameters:params suffix:CS_SERVER_URL_SUFFIX_SET_USER_TAGS success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                CS_Log_Info(@"User tags sent");

            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CS_Log_Warning(@"Error sending user tags: %@", [error description]);
                
            });
        }];
        
        
    });
    
}

-(void)getUserTagsWithSuccess:(void(^)(NSDictionary *responseObject))success
                      failure:(void(^)(NSError *error))failure {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode,
                                    [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode,
                                    [[CurioSDK shared] sessionCode], CURKeySessionCode,
                                    nil];
        
        [[CurioPostOffice shared] postRequestWithParameters:parameters suffix:CS_SERVER_URL_SUFFIX_GET_USER_TAGS success:^(id responseObject) {
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

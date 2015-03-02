//
//  CurioNotificationManager.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Marcus Frex on 17/11/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//


#import "CurioSDK.h"

@implementation CurioNotificationManager

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
        
        curioNotificationQueue = [NSOperationQueue new];
        [curioNotificationQueue setMaxConcurrentOperationCount:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPreviouslyFailedPushDataToServer:) name:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
        
    }
    return self;
}

/*- (NSString *) deviceToken {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults objectForKey:CS_CONST_DEV_TOK];
}*/

/*- (void) setDeviceToken:(NSString *) deviceToken {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:deviceToken forKey:CS_CONST_DEV_TOK];
    [userDefaults synchronize];
    
    
}*/

- (void) sendPreviouslyFailedPushDataToServer:(id) notif {
    
    NSArray *rNotifications = [[CurioDBToolkit shared] getStoredPushData];
    
    CS_Log_Info(@"Posting %lu remaining notification",(unsigned long)rNotifications.count);
    
    for (CurioPushData *notification in rNotifications) {
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        
        if (notification.pushId != nil && ![notification.pushId isEqualToString:@""] ) {
            [userInfo setObject:notification.pushId forKey: CURKeyPId];
        }
        
        [self sendPushData:userInfo];
        
    }
    
    [[CurioDBToolkit shared] deleteStoredPushData:rNotifications];
    
}


- (void) sendPushData:(NSDictionary *)userInfo {
    
    __weak CurioNotificationManager *weakSelf = self;
    
    [curioNotificationQueue addOperationWithBlock:^{
        
    @synchronized(weakSelf) {
        
        if (![[CurioSDK shared] sessionCodeRegisteredOnServer]) {
            
            CS_Log_Debug(@"No session code registered on server, push data will be inserted into DB...");
            
            BOOL result = [[CurioDBToolkit shared] addPushData:
             [[CurioPushData alloc] init:[[CurioUtil shared] nanos]
                                 deviceToken:[weakSelf deviceToken]
                                      pushId:(userInfo != nil ? [userInfo objectForKey: CURKeyPId] : nil)]];
            
            CS_Log_Info(@"Push data DB insert result is %d", result);
            
            
            return;
        }
        
        
        NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],CS_SERVER_URL_SUFFIX_PUSH_DATA];
        
        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        NSString *pushMsgId = nil;
        
        if(userInfo != nil){
            pushMsgId = [userInfo objectForKey: CURKeyPId];
        }
        
        if(pushMsgId == nil){
            pushMsgId = @"";
        }
        
        NSString *postBody = [[CurioUtil shared] dictToPostBody:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode,
                                                                 [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode,
                                                                 [[CurioSDK shared] sessionCode], CURKeySessionCode,
                                                                 pushMsgId, CURHttpParamPushId, // message Id
                                                                 [weakSelf deviceToken], CURHttpParamPushToken, //deviceToken
                                                                 [[CurioSDK shared] customId], CURHttpParamCustomId, //Custom id param
                                                                 nil]];
        
        NSData *dataPostBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
        
        CS_Log_Debug(@"\r\rSendPushData REQUEST;\rURL: %@,\rUserinfo: %@,\rPost body:\r%@\r\r",sUrl,CS_RM_STR_NEWLINE(userInfo),[postBody stringByReplacingOccurrencesOfString:@"&" withString:@"\r"]);
        
        [request setHTTPBody:dataPostBody];
        
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        
        CS_Log_Debug(@"\r\rRESPONSE for URL: %@,\rStatus code: %ld,\rResponse string: %@\r\r",sUrl,(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        BOOL failed = FALSE;
        
        if ((long)httpResponse.statusCode != 200) {
            CS_Log_Warning(@"Not ok: %ld, %@",(long)httpResponse.statusCode,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            failed = TRUE;
        }
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@ %@",(long)error.code, sUrl, error.localizedDescription);
            
            failed = TRUE;
        }
        
        
        if (failed) {
            
            [[CurioDBToolkit shared] addPushData:
             [[CurioPushData alloc] init:[[CurioUtil shared] nanos]
                                 deviceToken:[weakSelf deviceToken]
                                      pushId:(userInfo != nil ? [userInfo objectForKey: CURKeyPId] : nil)]];
            
            CS_Log_Warning(@"Adding push data to DB because it was not successfull");
            
        }
        
    }
    
    }];
}

- (BOOL) hasItem:(NSString *)item in:(NSString *)in {
    
    NSArray *items = in != nil ? [in componentsSeparatedByString:@","] : [NSArray new];
    
    __block BOOL ret = FALSE;
    
    [items enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL *stop) {
        
        //Stuff from preventing user mistakes
        NSString *check = [[obj stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        NSString *with = [[item stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        
        if ([check isEqualToString:with]) {
            ret = TRUE;
            *stop = TRUE;
        }
        
    }];
    
    return ret;
}

- (void) registerForNotifications {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *regNotificationTypes = [[CurioSettings shared] notificationTypes];
    
    BOOL hasSound =[self hasItem:CURNotificationTypeSound in:regNotificationTypes];
    BOOL hasAlert = [self hasItem:CURNotificationTypeAlert in:regNotificationTypes];
    BOOL hasBadge = [self hasItem:CURNotificationTypeBadge in:regNotificationTypes];
    
    CS_Log_Info(@"Registering for %@ %@ %@ notifications",
                (hasSound ? CURNotificationTypeSound : @"") ,
                (hasAlert ? CURNotificationTypeAlert : @"") ,
                (hasBadge ? CURNotificationTypeBadge : @""))
    
    
    
    // If iOS version is 8.0
    if ([app respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        
        UIUserNotificationType notificationType = ((hasSound ? UIUserNotificationTypeSound : 0) |
                                          (hasAlert ? UIUserNotificationTypeAlert : 0) |
                                          (hasBadge ? UIUserNotificationTypeBadge : 0));
        
        CS_Log_Info(@"Registering for >= 8.0 notifications");
        
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:notificationType categories:nil]];
        
        [app registerForRemoteNotifications];
    }
    else
        // If iOS version is less than 8.0
    {
        UIRemoteNotificationType notificationType = ((hasSound ? UIRemoteNotificationTypeSound : 0) |
                                            (hasAlert ? UIRemoteNotificationTypeAlert : 0) |
                                            (hasBadge ? UIRemoteNotificationTypeBadge : 0));
        
        CS_Log_Info(@"Registering for 8.0 < notifications");
        
        [app registerForRemoteNotificationTypes:notificationType];
    }
}

- (void) didRegisteredForNotifications:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    if ([self deviceToken] == nil) {
        [self setDeviceToken:token];
        
        [self sendPushData:[NSDictionary new]];
    }
    
    CS_Log_Info(@"Device token: %@",token);
    
    NSDictionary *notif = [[[CurioSDK shared] appLaunchOptions] objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Means app is started by push notification
    if (notif) {
        [self sendPushData:notif];
    }
    
}


- (void) didReceiveNotification:(NSDictionary *)userInfo {
    
    UIApplication *application = [UIApplication sharedApplication];
    
    // Means app resumed by push notification
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
        [self sendPushData:userInfo];
    else {
        CS_Log_Info(@"Received notification %@ and ignoring",userInfo);
    }
}


- (void) unregister {
    __weak CurioNotificationManager *weakSelf = self;
    
    [curioNotificationQueue addOperationWithBlock:^{
        
        @synchronized(weakSelf) {
            
            NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],CS_SERVER_URL_SUFFIX_UNREGISTER];
            
            NSURL *url = [NSURL URLWithString:sUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setHTTPShouldHandleCookies:NO];
            [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
            
            NSString *postBody = [[CurioUtil shared] dictToPostBody:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [weakSelf deviceToken], CURHttpParamPushToken, //deviceToken
                                                                     [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode, // visitorCode
                                                                     [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode, // trackingCode
                                                                     [[CurioSDK shared] sessionCode], CURKeySessionCode, //sessionCode
                                                                     [[CurioSDK shared] customId], CURHttpParamCustomId, //Custom id param
                                                                     nil]];
            
            NSData *dataPostBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
            
            CS_Log_Debug(@"\r\rUnregister REQUEST;\rURL: %@,\rPost body:\r%@\r\r",sUrl,[postBody stringByReplacingOccurrencesOfString:@"&" withString:@"\r"]);
            
            [request setHTTPBody:dataPostBody];
            
            
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            
            CS_Log_Debug(@"\r\rRESPONSE for URL: %@,\rStatus code: %ld,\rResponse string: %@\r\r",sUrl,(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            if ((long)httpResponse.statusCode != 200) {
                CS_Log_Warning(@"Not ok: %ld, %@",(long)httpResponse.statusCode,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }else {
                CS_Log_Debug(@"Successfully unregistered. Server response:%@ %ld",httpResponse.allHeaderFields,(long)httpResponse.statusCode);
            }
            
            if (error != nil) {
                CS_Log_Warning(@"Warning: %ld , %@ %@",(long)error.code, sUrl, error.localizedDescription);
            }
        }
        
    }];
}

@end

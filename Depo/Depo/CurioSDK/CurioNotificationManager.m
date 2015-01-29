//
//  CurioNotificationManager.m
//  CurioSDK
//
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postRemainingNotificationsToServer:) name:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
        
    }
    return self;
}

- (NSString *) deviceToken {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults objectForKey:CS_CONST_DEV_TOK];
}

- (void) setDeviceToken:(NSString *) deviceToken {
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:deviceToken forKey:CS_CONST_DEV_TOK];
    [userDefaults synchronize];
    
    
}

- (void) postRemainingNotificationsToServer:(id) notif {
    
    NSArray *rNotifications = [[CurioDBToolkit shared] getNotifications];
    
    CS_Log_Info(@"Posting %lu remaining notification",(unsigned long)rNotifications.count);
    
    for (CurioNotification *not in rNotifications) {
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        
        if (not.pushId != nil && ![not.pushId isEqualToString:@""] ) {
            [userInfo setObject:not.pushId forKey:@"pId"];
        }
        
        [self postToServer:userInfo];
        
    }
    
    [[CurioDBToolkit shared] deleteNotifications:rNotifications];
    
}


- (void) postToServer:(NSDictionary *)userInfo {
    
    CS_Log_Info(@".");
    
    __weak CurioNotificationManager *weakSelf = self;
    
    [curioNotificationQueue addOperationWithBlock:^{
        
    @synchronized(weakSelf) {
        
        if (![[CurioSDK shared] sessionCodeRegisteredOnServer]) {
            
            [[CurioDBToolkit shared] addNotification:
             [[CurioNotification alloc] init:[[CurioUtil shared] nanos]
                                 deviceToken:[weakSelf deviceToken]
                                      pushId:(userInfo != nil ? [userInfo objectForKey:@"pId"] : nil)]];
            
            CS_Log_Info(@"Adding notification to DB because not received an accepted session code yet");
            
            
            return;
        }
        
        
        NSString *sUrl = [NSString stringWithFormat:@"%@/%@",[[CurioSettings shared] serverUrl],CS_SERVER_URL_SUFFIX_PUSH_DATA];
        
        CS_Log_Debug(@"Notification URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(userInfo));
        
        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        NSString *postBody = [[CurioUtil shared] dictToPostBody:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [weakSelf deviceToken], @"pushToken", //deviceToken
                                                                 [[CurioUtil shared] vendorIdentifier], @"visitorCode",
                                                                 [[CurioSettings shared] trackingCode], @"trackingCode",
                                                                 [[CurioSDK shared] sessionCode], @"sessionCode",
                                                                 userInfo != nil ? [userInfo objectForKey:@"pId"] : nil, @"pushId", // old messageId
                                                                 nil]];
        
        NSData *dataPostBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
        
        CS_Log_Debug(@"Post-body: %@",postBody);
        
        [request setHTTPBody:dataPostBody];
        
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        
        CS_Log_Debug(@"Server response:%@ %ld",httpResponse.allHeaderFields,(long)httpResponse.statusCode);
        //    CS_Log_Info(@"Post response: %ld => %@",(long)httpResponse.statusCode,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
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
            
            [[CurioDBToolkit shared] addNotification:
             [[CurioNotification alloc] init:[[CurioUtil shared] nanos]
                                 deviceToken:[weakSelf deviceToken]
                                      pushId:(userInfo != nil ? [userInfo objectForKey:@"pId"] : nil)]];
            
            CS_Log_Warning(@"Adding notification to DB because it was not successfull");
            
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
    
    BOOL hasSound =[self hasItem:@"Sound" in:regNotificationTypes];
    BOOL hasAlert = [self hasItem:@"Alert" in:regNotificationTypes];
    BOOL hasBadge = [self hasItem:@"Badge" in:regNotificationTypes];
    
    CS_Log_Info(@"Registering for %@ %@ %@ notifications",
                (hasSound ? @"Sound" : @"") ,
                (hasAlert ? @"Alert" : @"") ,
                (hasBadge ? @"Badge" : @""))
    
    
    
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
    
    
    if ([self deviceToken] == nil || ![[self deviceToken] isEqualToString:token]) {
        [self setDeviceToken:token];
        
        [self postToServer:[NSDictionary new]];
    }
    
    CS_Log_Info(@"Device token: %@",token);
    
    NSDictionary *notif = [[[CurioSDK shared] appLaunchOptions] objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Means app is started by push notification
    if (notif) {
        [self postToServer:notif];
    }
    
}


- (void) didReceiveNotification:(NSDictionary *)userInfo {
    
    UIApplication *application = [UIApplication sharedApplication];
    
    // Means app resumed by push notification
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
        [self postToServer:userInfo];
    else {
        CS_Log_Info(@"Received notification %@ and ignoring",userInfo);
    }
}

@end

//
//  AppDelegate.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomAlertView.h"
#import "CustomConfirmView.h"
#import "MyViewController.h"
#import "MyNavigationController.h"
#import "BaseViewController.h"
#import "HomeController.h"
#import "SettingsController.h"
#import "SettingsUploadController.h"
#import "SettingsStorageController.h"
#import "FileListController.h"
#import "MapUtil.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "SyncUtil.h"
#import "PreLoginController.h"
#import "LoginController.h"
#import "PostLoginSyncPrefController.h"

#import "MigrateStatusController.h"
#import "TermsController.h"

#import "Adjust.h"
#import "ACTReporter.h"
#import <SplunkMint-iOS/SplunkMint-iOS.h>
#import "CurioSDK.h"
#import "ContactSyncSDK.h"

#import "ReachabilityManager.h"

#import "MMWormhole.h"

//TODO MACRO TANIMLANACAK (extension group id için)


//TODO info'larda version update

@implementation AppDelegate

@synthesize session;
@synthesize base;
@synthesize tokenManager;
@synthesize mapUtil;
@synthesize progress;
@synthesize syncManager;
@synthesize wormhole;
@synthesize uploadQueue;
@synthesize activatedFromBackground;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    session = [[AppSession alloc] init];
    uploadQueue = [[UploadQueue alloc] init];
    syncManager = [[SyncManager alloc] init];
    mapUtil = [[MapUtil alloc] init];
    wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:GROUP_NAME_SUITE_NSUSERDEFAULTS optionalDirectory:EXTENSION_WORMHOLE_DIR];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Adjust initialization
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:@"hlqdgtbmrdb9" environment:ADJEnvironmentProduction];
    [Adjust appDidLaunch:adjustConfig];
    
    //Google Conversion initialization
    [ACTConversionReporter reportWithConversionID:@"946883454" label:@"gJYdCOLv4wcQ_pbBwwM" value:@"0.00" isRepeatable:NO];
    
    //BugSense integration
    [[Mint sharedInstance] initAndStartSession:@"13ceffcf"];

    // TODO
    //Curio integration
    [[CurioSDK shared] startSession:@"http://curio.turkcell.com.tr/api/v2" apiKey:@"cab314f33df2514764664e5544def586" trackingCode:@"KL2XNFIE" sessionTimeout:4 periodicDispatchEnabled:YES dispatchPeriod:1 maxCachedActivitiyCount:1000 loggingEnabled:YES logLevel:3 registerForRemoteNotifications:YES notificationTypes:@"Sound,Badge,Alert" fetchLocationEnabled:NO maxValidLocationTimeInterval:0 appLaunchOptions:launchOptions]; // Live
//    [[CurioSDK shared] startSession:@"https://curiotest.turkcell.com.tr/api/v2" apiKey:@"7dfb5740be8111e4a44b63ca635716aa" trackingCode:@"OO5CO5YS" sessionTimeout:4 periodicDispatchEnabled:NO dispatchPeriod:1 maxCachedActivitiyCount:1000 loggingEnabled:YES logLevel:3 registerForRemoteNotifications:YES notificationTypes:@"Sound,Badge,Alert" fetchLocationEnabled:NO maxValidLocationTimeInterval:0 appLaunchOptions:launchOptions]; // NewTest

    [[CurioSDK shared] sendEvent:@"application_started" eventValue:@"true"];

    [self addInitialBgImage];

    progress = [[MBProgressHUD alloc] initWithWindow:self.window];
    progress.opacity = 0.4f;
    [self.window addSubview:progress];

    tokenManager = [[TokenManager alloc] init];
    tokenManager.delegate = self;
    
    if (launchOptions != nil && launchOptions[@"action"] != nil) {
        NSString *actionString = launchOptions[@"action"];
        NSLog(@"Notification Action: %@", actionString);
        
        if ([actionString isEqualToString:@"main"]) {
            self.notifitacionAction = NotificationActionMain;
        } else if ([actionString isEqualToString:@"sync_settings"]) {
            self.notifitacionAction = NotificationActionSyncSettings;
        } else if ([actionString isEqualToString:@"floating_menu"]) {
            self.notifitacionAction = NotificationActionFloatingMenu;
        } else if ([actionString isEqualToString:@"packages"]) {
            self.notifitacionAction = NotificationActionPackages;
        }
    }
    
    [ReachabilityManager currentManager];
    
    if(![ReachabilityManager isReachable]) {
        UIAlertView *noConnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"ConnectionErrorWarning", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"SubmitButtonTitle", @"") otherButtonTitles:nil];
        [noConnAlert show];
    } else {
        if([CacheUtil readRememberMeToken] != nil) {
            [tokenManager requestToken];
            [self showMainLoading];
        } else {
            if(![AppUtil readFirstVisitOverFlag]) {
                [self triggerPreLogin];
            } else {
                [self triggerLogin];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRequiredNotificationRaised) name:LOGIN_REQ_NOTIFICATION object:nil];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void) triggerPreLogin {
    PreLoginController *preLogin = [[PreLoginController alloc] init];
    self.window.rootViewController = preLogin;
}

- (void) triggerPostTermsAndMigration {
    if([ReachabilityManager isReachableViaWiFi]) {
        NSString *cachedMsisdn = [CacheUtil readCachedMsisdnForPostMigration];
        NSString *cachedPass = [CacheUtil readCachedPassForPostMigration];
        if(cachedMsisdn != nil && cachedPass != nil) {
            [tokenManager requestTokenByMsisdn:cachedMsisdn andPass:cachedPass shouldRememberMe:[CacheUtil readCachedRememberMeForPostMigration]];
            [self showMainLoading];
        } else {
            LoginController *login = [[LoginController alloc] init];
            MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
            self.window.rootViewController = loginNav;
        }
    } else if([ReachabilityManager isReachableViaWWAN]) {
        [self.window.rootViewController.view removeFromSuperview];
        [tokenManager requestRadiusLogin];
        [self showMainLoading];
    }
}

- (void) triggerLogin {
    if([ReachabilityManager isReachableViaWiFi]) {
        LoginController *login = [[LoginController alloc] init];
        MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = loginNav;
    } else if([ReachabilityManager isReachableViaWWAN]) {
        [self.window.rootViewController.view removeFromSuperview];
        [tokenManager requestRadiusLogin];
        [self showMainLoading];
    }
}

- (void) loginRequiredNotificationRaised {
    BOOL shouldShowLogin = YES;
    if([self.window.rootViewController isKindOfClass:[MyNavigationController class]]) {
        MyNavigationController *currentNav = (MyNavigationController *) self.window.rootViewController;
        if([currentNav.viewControllers count] > 0) {
            id controllerAtTopStack = [currentNav.viewControllers objectAtIndex:[currentNav.viewControllers count] -1];
            if([controllerAtTopStack isKindOfClass:[LoginController class]]) {
                shouldShowLogin = NO;
            }
        }
    }
    if(shouldShowLogin) {
        [self triggerLogout];
        /*
        LoginController *login = [[LoginController alloc] init];
        MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = loginNav;
         */
    }
}

- (void) triggerPostLogin {
    if(APPDELEGATE.session.newUserFlag) {
        [self tokenManagerProvisionNeeded];
    } else if(APPDELEGATE.session.migrationUserFlag) {
        [self tokenManagerMigrationInProgress];
    } else {
        [tokenManager requestUserInfo];
    }
}

- (void) startOpeningPage {
    [APPDELEGATE.uploadQueue.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(uploadTasks) {
            for(NSURLSessionUploadTask *task in uploadTasks) {
                if([task.originalRequest.URL absoluteString]) {
                    [APPDELEGATE.session addBgOngoingTaskUrl:[task.originalRequest.URL absoluteString]];
                }
            }
        }
        [self triggerAutoSynchronization];
    }];

    if (self.notifitacionAction > 0) {
        if (self.notifitacionAction == NotificationActionSyncSettings) {
            [self triggerSyncSettings];
        } else if (self.notifitacionAction == NotificationActionPackages) {
            [self triggerStorageSettings];
        } else if (self.notifitacionAction == NotificationActionFloatingMenu) {
            [self triggerFloatingMenu];
        } else {
            [self triggerHome];
        }
    } else {
        [self triggerHome];
    }
}

- (void) triggerHome {
    MyViewController *homeController = [[HomeController alloc] init];
    base = [[BaseViewController alloc] initWithRootViewController:homeController];
    [self.window setRootViewController:base];
}

- (void) triggerSyncSettings {
    MyViewController *settingsController = [[SettingsController alloc] init];
    base = [[BaseViewController alloc] initWithRootViewController:settingsController];
    [self.window setRootViewController:base];
    
    SettingsUploadController *uploadController = [[SettingsUploadController alloc] init];
    uploadController.nav = settingsController.nav;
    [settingsController.nav pushViewController:uploadController animated:NO];
}

- (void) triggerStorageSettings {
    MyViewController *settingsController = [[SettingsController alloc] init];
    base = [[BaseViewController alloc] initWithRootViewController:settingsController];
    [self.window setRootViewController:base];
    
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
    storageController.nav = settingsController.nav;
    [settingsController.nav pushViewController:storageController animated:NO];
}

- (void) triggerFloatingMenu {
    MyViewController *fileListController = [[FileListController alloc] init];
    base = [[BaseViewController alloc] initWithRootViewController:fileListController];
    [self.window setRootViewController:base];
    [base floatingAddButtonDidOpenMenu];
}

- (void) triggerAutoSynchronization {
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        [self startAutoSync];
    }
}

- (void) triggerLogout {
    // Tekrar 3G radius loginine girdiği için commentlendi
//    [tokenManager requestLogout];

    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations) {
        [req cancel];
        [req setDelegate:nil];
    }

    [self.session stopAudioItem];
    [self.session cleanoutAfterLogout];
    [CacheUtil resetRememberMeToken];
    [uploadQueue cancelAllUploads];

    LoginController *login = [[LoginController alloc] init];
    MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
    self.window.rootViewController = loginNav;
}

- (void) tokenManagerInadequateInfo {
}

- (void) tokenManagerDidFailReceivingToken {
    [self hideMainLoading];
    LoginController *login = [[LoginController alloc] init];
    MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
    self.window.rootViewController = loginNav;
}

- (void) tokenManagerDidReceiveBaseUrl {
    [self hideMainLoading];
    
    if(![AppUtil readFirstVisitOverFlag]) {
        PostLoginSyncPrefController *imgSync = [[PostLoginSyncPrefController alloc] init];
        MyNavigationController *imgSyncNav = [[MyNavigationController alloc] initWithRootViewController:imgSync];
        self.window.rootViewController = imgSyncNav;
    } else {
//        [self triggerHome];
        [self startOpeningPage];
    }
}

- (void) tokenManagerDidFailReceivingBaseUrl {
    [self hideMainLoading];
//    [self triggerHome];
    [self startOpeningPage];
}

- (void) tokenManagerDidReceiveToken {
    [tokenManager requestUserInfo];
}

- (void) tokenManagerDidReceiveUserInfo {
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidFailReceivingUserInfo {
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidReceiveConstants {
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidFailReceivingConstants {
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerProvisionNeeded {
    TermsController *termsPage = [[TermsController alloc] init];
    [self.window setRootViewController:termsPage];
}

- (void) tokenManagerMigrationInProgress {
    MigrateStatusController *migrationPage = [[MigrateStatusController alloc] init];
    [self.window setRootViewController:migrationPage];
}

- (void) startAutoSync {
    [syncManager decideAndStartAutoSync];
}

- (void) stopAutoSync {
//    [syncManager stopAutoSync];
}

- (void) addInitialBgImage {
    UIImage *bgImg = [UIImage imageNamed:@"Default.png"];
    if(IS_IPHONE_5) {
        bgImg = [UIImage imageNamed:@"Default-568h@2x.png"];
    }
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:bgImg];
    bgImgView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    [self.window addSubview:bgImgView];
}

- (void) showCustomAlert:(CustomAlertView *) alertView {
    [self.window addSubview:alertView];
    [self.window bringSubviewToFront:alertView];
}

- (void) showCustomConfirm:(CustomConfirmView *) alertView {
    [self.window addSubview:alertView];
    [self.window bringSubviewToFront:alertView];
}

- (void) showMainLoading {
    [progress show:YES];
    [self.window bringSubviewToFront:progress];
}

- (void) hideMainLoading {
    [progress hide:YES];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
    [self application:application didFinishLaunchingWithOptions:userInfo];
    
    NSLog(@"didReceiveRemoteNotification CALLED.");
    if (userInfo != nil) {
        NSLog(@"didReceiveRemoteNotification user info received.");
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
    [self application:application didFinishLaunchingWithOptions:userInfo];
    
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler CALLED");
    if (userInfo != nil) {
        NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler user info received.");
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[CurioNotificationManager shared] didRegisteredForNotifications:deviceToken];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //TODO sil
    /*
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:@"Background fetch çalıştı."];
    [notification setFireDate:[NSDate date]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
     */
    
    [APPDELEGATE.uploadQueue.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(uploadTasks) {
            for(NSURLSessionUploadTask *task in uploadTasks) {
                if([task.originalRequest.URL absoluteString]) {
                    [APPDELEGATE.session addBgOngoingTaskUrl:[task.originalRequest.URL absoluteString]];
                }
            }
        }
        [self triggerAutoSynchronization];
    }];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /* auto contact sync kaldirildi
    if ([ContactSyncSDK automated]){
        [ContactSyncSDK sleep];
    }
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    activatedFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [SyncUtil resetBadgeCount];

    if(session != nil) {
        [session checkLatestContactSyncStatus];
    }
    
    if(activatedFromBackground) {
        [APPDELEGATE.uploadQueue.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if(uploadTasks) {
                for(NSURLSessionUploadTask *task in uploadTasks) {
                    if([task.originalRequest.URL absoluteString]) {
                        [APPDELEGATE.session addBgOngoingTaskUrl:[task.originalRequest.URL absoluteString]];
                    }
                }
            }
            [self triggerAutoSynchronization];
        }];
    } else {
        // eğer backgrounddan gelmiyorsa bir sonraki auto sync bloğununun okunmasını engelleyen lock kaldırılıyor
        [SyncUtil unlockAutoSyncBlockInProgress];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CurioSDK shared] endSession];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    NSLog(@"At handleEventsForBackgroundURLSession");
}

@end

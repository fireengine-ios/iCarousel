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
#import "MapUtil.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "SyncUtil.h"
#import "PreLoginController.h"
#import "LoginController.h"
#import "PostLoginSyncPhotoController.h"
#import "Reachability.h"

#import "MigrateStatusController.h"
#import "TermsController.h"

#import "Adjust.h"
#import "ACTReporter.h"
#import <SplunkMint-iOS/SplunkMint-iOS.h>
#import "CurioSDK.h"
#import "ContactSyncSDK.h"

@implementation AppDelegate

@synthesize session;
@synthesize base;
@synthesize tokenManager;
@synthesize mapUtil;
@synthesize progress;
@synthesize syncManager;
@synthesize uploadQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    session = [[AppSession alloc] init];
    
    uploadQueue = [[UploadQueue alloc] init];
    
    mapUtil = [[MapUtil alloc] init];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Adjust initialization
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:@"hlqdgtbmrdb9" environment:ADJEnvironmentProduction];
    [Adjust appDidLaunch:adjustConfig];
    
    //Google Conversion initialization
    [ACTConversionReporter reportWithConversionID:@"946883454" label:@"gJYdCOLv4wcQ_pbBwwM" value:@"0.00" isRepeatable:NO];
    
    //BugSense integration
    [[Mint sharedInstance] initAndStartSession:@"13ceffcf"];

    //Curio integration
    [[CurioSDK shared] startSession:@"http://curio.turkcell.com.tr/api/v2/" apiKey:@"cab314f33df2514764664e5544def586" trackingCode:@"KL2XNFIE" sessionTimeout:4 periodicDispatchEnabled:YES dispatchPeriod:1 maxCachedActivitiyCount:1000 loggingEnabled:YES logLevel:0 registerForRemoteNotifications:YES notificationTypes:@"Sound,Badge,Alert" appLaunchOptions:launchOptions];

    [self addInitialBgImage];

    progress = [[MBProgressHUD alloc] initWithWindow:self.window];
    progress.opacity = 0.4f;
    [self.window addSubview:progress];

    tokenManager = [[TokenManager alloc] init];
    tokenManager.delegate = self;
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi) {
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
    } else if(networkStatus == kReachableViaWWAN) {
        if(![AppUtil readFirstVisitOverFlag]) {
            [self triggerPreLogin];
        } else {
            [self triggerLogin];
        }
    } else {
        UIAlertView *noConnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"ConnectionErrorWarning", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"SubmitButtonTitle", @"") otherButtonTitles:nil];
        [noConnAlert show];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) triggerPreLogin {
    PreLoginController *preLogin = [[PreLoginController alloc] init];
    self.window.rootViewController = preLogin;
}

- (void) triggerLogin {
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi) {
        LoginController *login = [[LoginController alloc] init];
        MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = loginNav;
    } else if(networkStatus == kReachableViaWWAN) {
        [self.window.rootViewController.view removeFromSuperview];
        [tokenManager requestRadiusLogin];
        [self showMainLoading];
    }
}

- (void) triggerPostLogin {
    [tokenManager requestUserInfo];
}

- (void) triggerHome {
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        [self startAutoSync];
    }
    
    MyViewController *homeController = [[HomeController alloc] init];
    base = [[BaseViewController alloc] initWithRootViewController:homeController];
    [self.window setRootViewController:base];
}

- (void) triggerLogout {
    [tokenManager requestLogout];

    self.session.user = nil;
    [CacheUtil resetRememberMeToken];
//    [self triggerLogin];
    LoginController *login = [[LoginController alloc] init];
    MyNavigationController *loginNav = [[MyNavigationController alloc] initWithRootViewController:login];
    self.window.rootViewController = loginNav;
}

- (void) tokenManagerInadequateInfo {
}

- (void) tokenManagerDidFailReceivingToken {
}

- (void) tokenManagerDidReceiveBaseUrl {
    [self hideMainLoading];
    
    if(![AppUtil readFirstVisitOverFlag]) {
        PostLoginSyncPhotoController *imgSync = [[PostLoginSyncPhotoController alloc] init];
        MyNavigationController *imgSyncNav = [[MyNavigationController alloc] initWithRootViewController:imgSync];
        self.window.rootViewController = imgSyncNav;
    } else {
        [self triggerHome];
    }
}

- (void) tokenManagerDidFailReceivingBaseUrl {
    [self hideMainLoading];
    [self triggerHome];
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

- (void) tokenManagerProvisionNeeded {
    TermsController *termsPage = [[TermsController alloc] init];
    [self.window setRootViewController:termsPage];
}

- (void) tokenManagerMigrationInProgress {
    MigrateStatusController *migrationPage = [[MigrateStatusController alloc] init];
    [self.window setRootViewController:migrationPage];
}

- (void) startAutoSync {
    if(!syncManager) {
        self.syncManager = [[SyncManager alloc] init];
        if(![SyncUtil readFirstTimeSyncFlag]) {
            [syncManager startFirstTimeSync];
        } else {
            [syncManager startAutoSync];
            [syncManager manuallyCheckIfAlbumChanged];
        }
    }
}

- (void) stopAutoSync {
    [syncManager stopAutoSync];
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
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[CurioNotificationManager shared] didRegisteredForNotifications:deviceToken];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    EnableOption contactSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncContacts];

    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        [self.syncManager manuallyCheckIfAlbumChanged];
    }

    if(contactSyncFlag == EnableOptionAuto || contactSyncFlag == EnableOptionOn) {
        //TODO uncomment and test
//        [ContactSyncSDK runInBackground];
    }

    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [SyncUtil resetBadgeCount];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CurioSDK shared] endSession];
}

@end

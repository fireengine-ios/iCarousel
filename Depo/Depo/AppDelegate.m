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
#import "CustomEntryPopupView.h"
#import "MyViewController.h"
#import "MyNavigationController.h"
#import "BaseViewController.h"
#import "HomeController.h"
#import "SettingsController.h"
#import "SettingsUploadController.h"
#import "SettingsStorageController.h"
#import "RevisitedStorageController.h"
#import "OTPController.h"
#import "SignupController.h"

#import "FileListController.h"
#import "MapUtil.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "SyncUtil.h"
#import "PreLoginController.h"
#import "LoginController.h"
#import "PostLoginSyncPrefController.h"
#import "RevisitedGroupedPhotosController.h"

#import "MigrateStatusController.h"
#import "TermsController.h"

#import "Adjust.h"
#import "ACTReporter.h"
#import <SplunkMint/SplunkMint.h>
#import "ContactSyncSDK.h"
#import "AppConstants.h"

#import "ReachabilityManager.h"

#import "MMWormhole.h"

#import "UpdaterController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BgViewController.h"
#import "WelcomeController.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "MPush.h"

#import <DropboxSDK/DropboxSDK.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Reachability.h"

#import "BaseBgController.h"
#import "AppRater.h"

//TODO info'larda version update

#define NO_CONN_ALERT_TAG 111

@implementation AppDelegate

@synthesize session;
@synthesize base;
@synthesize tokenManager;
@synthesize mapUtil;
@synthesize progress;
@synthesize wormhole;
@synthesize activatedFromBackground;
@synthesize loginInProgress;
//@synthesize notificationAction;
@synthesize notificationActionUrl;
@synthesize locInfoPopup;
@synthesize noConnPopupShown;
@synthesize noConnAlert;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [self.window setRootViewController:[BgViewController alloc]];
    
    IGLog(@"AppDelegate didFinishLaunchingWithOptions");
    NSLog(@"AppDelegate didFinishLaunchingWithOptions");
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
        [[UIView appearanceWhenContainedIn:[UIAlertView class], nil] setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
    }
    
#ifdef LOG2FILE
    
    [self logToFiles];
    
#endif
    
    [Fabric with:@[[Crashlytics class]]];
    
    session = [[AppSession alloc] init];
    mapUtil = [[MapUtil alloc] init];
    wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:GROUP_NAME_SUITE_NSUSERDEFAULTS optionalDirectory:EXTENSION_WORMHOLE_DIR];
    
    //mahir: loc update geldiğinden bg fetch cikarildi simdilik    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //Adjust initialization
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:@"hlqdgtbmrdb9" environment:ADJEnvironmentProduction];
    [Adjust appDidLaunch:adjustConfig];
    
    //Google Conversion initialization
    [ACTConversionReporter reportWithConversionID:@"946883454" label:@"gJYdCOLv4wcQ_pbBwwM" value:@"0.00" isRepeatable:NO];
    
    //TODO BugSense integration
    //    [[Mint sharedInstance] initAndStartSession:@"13ceffcf"];
    
    
    NSInteger types;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.f) {
        types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
    } else {
        types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
    }
    
    //    [MPush setShouldShowDebugLogs:YES];
    if(![AppUtil readFirstVisitOverFlag]) {
        [MPush setLocationEnabled:NO];
    } else {
        if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            [MPush setLocationEnabled:YES];
        } else {
            [MPush setLocationEnabled:NO];
        }
    }
    
    [MPush registerForRemoteNotificationTypes:types];
    
    [MPush applicationDidFinishLaunchingWithOptions:launchOptions];
    
    //Curio integrationc
    [[CurioSDK shared] startSession:@"http://curio.turkcell.com.tr/api/v2" apiKey:@"cab314f33df2514764664e5544def586" trackingCode:@"KL2XNFIE" sessionTimeout:30 periodicDispatchEnabled:YES dispatchPeriod:5 maxCachedActivitiyCount:10 loggingEnabled:NO logLevel:0 registerForRemoteNotifications:NO notificationTypes:@"Sound,Badge,Alert" fetchLocationEnabled:NO maxValidLocationTimeInterval:600 delegate:self appLaunchOptions:launchOptions];
    
    [[CurioSDK shared] sendEvent:@"ApplicationStarted" eventValue:@"true"];
    [MPush hitTag:@"ApplicationStarted" withValue:@"true"];
    
    DBSession *dbSession = [[DBSession alloc] initWithAppKey:@"422fptod5dlxrn8" appSecret:@"umjclqg3juoyihd" root:kDBRootDropbox]; // initWithAppKey:@"zeddgylajxc1op8" appSecret:@"kn9u1e77bzlk103"
    [DBSession setSharedSession:dbSession];
    
    [self addInitialBgImage];
    
    progress = [[MBProgressHUD alloc] initWithWindow:self.window];
    progress.opacity = 0.4f;
    [self.window addSubview:progress];
    
    tokenManager = [[TokenManager alloc] init];
    tokenManager.delegate = self;
    
    [self assignNotificationActionByLaunchOptions:launchOptions];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        [[LocationManager sharedInstance] startLocationManager];
    }
    
    [ReachabilityManager currentManager];
    
    if(![ReachabilityManager isReachable]) {
        IGLog(@"AppDelegate ReachabilityManager notReachable");
        
        noConnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"ConnectionErrorWarning", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"SubmitButtonTitle", @"") otherButtonTitles:nil];
        noConnAlert.delegate = self;
        noConnAlert.tag = NO_CONN_ALERT_TAG;
        [noConnAlert show];
        noConnPopupShown = YES;
    } else {
        IGLog(@"AppDelegate UpdaterController called");
        
        UpdaterController *updaterController = [UpdaterController initWithUpdateURL:UPDATER_SDK_URL delegate:self postProperties:NO];
        [self.window addSubview:updaterController];
        [updaterController getUpdateInformation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRequiredNotificationRaised) name:LOGIN_REQ_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
    
    //    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

//    // App Rater
//    [AppRater sharedInstance].daysUntilPrompt = 5;
//    [AppRater sharedInstance].launchesUntilPrompt = 10;
//    [AppRater sharedInstance].remindMeDaysUntilPrompt = 15;
//    [AppRater sharedInstance].remindMeLaunchesUntilPrompt = 10;
//    // [AppRater sharedInstance].preferredLanguage = @"en";
//    [[AppRater sharedInstance] appLaunched];
    
    [self handleURLCache];
    
    // Cancel all notifications that is scheduled before
    if(![AppUtil readAppFirstLaunchFlag]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [AppUtil writeAppFirstLaunchFlag];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)handleURLCache {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

- (void) assignNotificationActionByLaunchOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil && (launchOptions[@"action"] != nil || launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil)) {
        NSString *actionString = launchOptions[@"action"];
        if(actionString == nil && launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
            UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
            actionString = [localNotification userInfo][@"action"];
        }
        
//        if ([actionString isEqualToString:@"main"]) {
//            self.notificationAction = NotificationActionMain;
//        } else if ([actionString isEqualToString:@"sync_settings"]) {
//            self.notificationAction = NotificationActionSyncSettings;
//        } else if ([actionString isEqualToString:@"floating_menu"]) {
//            self.notificationAction = NotificationActionFloatingMenu;
//        } else if ([actionString isEqualToString:@"packages"]) {
//            self.notificationAction = NotificationActionPackages;
//        } else if ([actionString isEqualToString:@"photos_videos"]) {
//            self.notificationAction = NotificationActionPhotos;
//        } else if([actionString hasPrefix:@"http"]) {
//            self.notificationAction = NotificationActionWeb;
//            self.notificationActionUrl = actionString;
//        }
        
        if ([actionString isEqualToString:@"main"]) {
            APPDELEGATE.session.notificationAction = NotificationActionMain;
        } else if ([actionString isEqualToString:@"sync_settings"]) {
            APPDELEGATE.session.notificationAction = NotificationActionSyncSettings;
        } else if ([actionString isEqualToString:@"floating_menu"]) {
            APPDELEGATE.session.notificationAction = NotificationActionFloatingMenu;
        } else if ([actionString isEqualToString:@"packages"]) {
            APPDELEGATE.session.notificationAction = NotificationActionPackages;
        } else if ([actionString isEqualToString:@"photos_videos"]) {
            APPDELEGATE.session.notificationAction = NotificationActionPhotos;
        } else if([actionString hasPrefix:@"http"]) {
            APPDELEGATE.session.notificationAction = NotificationActionWeb;
            self.notificationActionUrl = actionString;
        }
    }
}

- (BOOL) isTurkcell {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    return [mcc isEqualToString:@"286"] && [mnc isEqualToString:@"01"];
}

- (void) triggerPreLogin {
    PreLoginController *preLogin = [[PreLoginController alloc] init];
    self.window.rootViewController = preLogin;
}

- (void) triggerPostTermsAndMigration {
    
    NSString *cachedMsisdn = [CacheUtil readCachedMsisdnForPostMigration];
    NSString *cachedPass = [CacheUtil readCachedPassForPostMigration];
    if(cachedMsisdn != nil && cachedPass != nil) {
        [tokenManager requestTokenByMsisdn:cachedMsisdn andPass:cachedPass shouldRememberMe:[CacheUtil readCachedRememberMeForPostMigration]];
        [self showMainLoading];
    } else {
        if([ReachabilityManager isReachableViaWiFi]
           || ![self isTurkcell]) {
            //WelcomeController *welcomePage = [[WelcomeController alloc] init];
            LoginController *loginController = [[LoginController alloc] init];
            MyNavigationController *welcomeNav = [[MyNavigationController alloc] initWithRootViewController:loginController];
            self.window.rootViewController = welcomeNav;
        } else if([ReachabilityManager isReachableViaWWAN]) {
            [self.window.rootViewController.view removeFromSuperview];
            [tokenManager requestRadiusLogin];
            [self showMainLoading];
        }
    }
}

- (void) triggerLogin {
    if([ReachabilityManager isReachableViaWiFi] || ![self isTurkcell]) {
        IGLog(@"AppDelegate Welcome Screen triggered");
        //WelcomeController *welcomePage = [[WelcomeController alloc] init];
        LoginController *loginController = [[LoginController alloc] init];
        MyNavigationController *welcomeNav = [[MyNavigationController alloc] initWithRootViewController:loginController];
        self.window.rootViewController = welcomeNav;
    } else if([ReachabilityManager isReachableViaWWAN]) {
        IGLog(@"AppDelegate Radius Login triggered");
        [self.window.rootViewController.view removeFromSuperview];
        [tokenManager requestRadiusLogin];
        loginInProgress = YES;
        [self showMainLoading];
    }
}

- (void) loginRequiredNotificationRaised {
    IGLog(@"AppDelegate - loginRequiredNotificationRaised");
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
    }
}

- (void) triggerPostLogin {
    if(APPDELEGATE.session.newUserFlag) {
        [self tokenManagerProvisionNeeded];
    } else if(APPDELEGATE.session.migrationUserFlag) {
        [self tokenManagerMigrationInProgress];
    } else {
        [tokenManager requestEulaCheck];
    }
}

- (void) startOpeningPage {
    /*
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
     */
    
    [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
    }];
    
    [self triggerAutoSynchronization];
    
    if (APPDELEGATE.session.notificationAction > 0) {
        if (APPDELEGATE.session.notificationAction == NotificationActionSyncSettings) {
            [self triggerSyncSettings];
        } else if (APPDELEGATE.session.notificationAction == NotificationActionPackages) {
            [self triggerStorageSettings];
        } else if (APPDELEGATE.session.notificationAction == NotificationActionFloatingMenu) {
            [self triggerFloatingMenu];
        } else if (APPDELEGATE.session.notificationAction == NotificationActionPhotos) {
            [self triggerPhotosAndVideos];
        } else if (APPDELEGATE.session.notificationAction == NotificationActionWeb){
            if(notificationActionUrl != nil && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:notificationActionUrl]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notificationActionUrl]];
            }
            [self triggerHome];
        } else {
            [self triggerHome];
        }
    } else {
        [self triggerHome];
    }
}

- (void) triggerHome {
    SEL isRegisteredForRemoteNotificationsSel = NSSelectorFromString(@"isRegisteredForRemoteNotifications");
    if([[UIApplication sharedApplication] respondsToSelector:isRegisteredForRemoteNotificationsSel]) {
        if([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
            [[CurioSDK shared] sendEvent:@"NotificationPermission" eventValue:@"granted"];
            [MPush hitTag:@"NotificationPermission" withValue:@"granted"];
        } else {
            [[CurioSDK shared] sendEvent:@"NotificationPermission" eventValue:@"denied"];
            [MPush hitTag:@"NotificationPermission" withValue:@"denied"];
        }
    }
    self.base = [[BaseViewController alloc] init];
    [self.window setRootViewController:base];
}

- (void) triggerPhotosAndVideos {
    MyViewController *photosController = [[RevisitedGroupedPhotosController alloc] init];
    self.base = [[BaseViewController alloc] initWithRootViewController:photosController];
    [self.window setRootViewController:base];
}

- (void) triggerSyncSettings {
    MyViewController *settingsController = [[SettingsController alloc] init];
    self.base = [[BaseViewController alloc] initWithRootViewController:settingsController];
    [self.window setRootViewController:base];
    
    SettingsUploadController *uploadController = [[SettingsUploadController alloc] init];
    uploadController.nav = settingsController.nav;
    [settingsController.nav pushViewController:uploadController animated:NO];
}

- (void) triggerStorageSettings {
    MyViewController *settingsController = [[SettingsController alloc] init];
    self.base = [[BaseViewController alloc] initWithRootViewController:settingsController];
    [self.window setRootViewController:base];
    
    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    storageController.nav = settingsController.nav;
    [settingsController.nav pushViewController:storageController animated:NO];
}

- (void) triggerFloatingMenu {
    MyViewController *fileListController = [[FileListController alloc] init];
    self.base = [[BaseViewController alloc] initWithRootViewController:fileListController];
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
    
    IGLog(@"AppDelegate Logged out");
    
    //    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations) {
    //        [req cancel];
    //        [req setDelegate:nil];
    //    }
    
    [self.session stopAudioItem];
    [self.session cleanoutAfterLogout];
    [CacheUtil resetRememberMeToken];
    [[UploadQueue sharedInstance] cancelAllUploads];
    if([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
    }
    
    //    WelcomeController *welcomePage = [[WelcomeController alloc] init];
    LoginController *loginController = [[LoginController alloc] init];
    MyNavigationController *welcomeNav = [[MyNavigationController alloc] initWithRootViewController:loginController];
    self.window.rootViewController = welcomeNav;
}

- (void) tokenManagerInadequateInfo {
}

- (void) tokenManagerDidFailReceivingToken: (NSString*) errorMessage {
    IGLog(@"AppDelegate tokenManagerDidFailReceivingToken");
    loginInProgress = NO;
    
    [self hideMainLoading];
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        [self.window setRootViewController:[[BaseBgController alloc] init]];
    } else {
        //        WelcomeController *welcomePage = [[WelcomeController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([errorMessage isEqualToString:NSLocalizedString(@"NoConnErrorMessage", @"")]) {
                UIAlertView *noConnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"ConnectionErrorWarning", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"SubmitButtonTitle", @"") otherButtonTitles:nil];
                noConnAlert.delegate = self;
                noConnAlert.tag = NO_CONN_ALERT_TAG;
                [noConnAlert show];
            }
            else {
                LoginController *loginController = [[LoginController alloc] init];
                MyNavigationController *welcomeNav = [[MyNavigationController alloc] initWithRootViewController:loginController];
                self.window.rootViewController = welcomeNav;
            }
        });
       
    }
}

- (void) tokenManagerDidReceiveBaseUrl {
    IGLog(@"AppDelegate tokenManagerDidReceiveBaseUrl");
    
    [self hideMainLoading];
    
    if(loginInProgress) {
        [SyncUtil unlockAutoSyncBlockInProgress];
        [self triggerAutoSynchronization];
        loginInProgress = NO;
    }
    
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
    IGLog(@"AppDelegate tokenManagerDidFailReceivingBaseUrl");
    
    [self hideMainLoading];
    //    [self triggerHome];
    [self startOpeningPage];
}

- (void) tokenManagerDidReceiveToken {
    IGLog(@"AppDelegate tokenManagerDidReceiveToken");
    [tokenManager requestUserInfo];
}

- (void) tokenManagerDidReceiveUserInfo {
    IGLog(@"AppDelegate tokenManagerDidReceiveUserInfo");
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidFailReceivingUserInfo {
    IGLog(@"AppDelegate tokenManagerDidFailReceivingUserInfo");
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidReceiveConstants {
    IGLog(@"AppDelegate tokenManagerDidReceiveConstants");
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerDidFailReceivingConstants {
    IGLog(@"AppDelegate tokenManagerDidFailReceivingConstants");
    [tokenManager requestBaseUrl];
}

- (void) tokenManagerProvisionNeeded {
    IGLog(@"AppDelegate tokenManagerProvisionNeeded");
    loginInProgress = NO;
    TermsController *termsPage = [[TermsController alloc] init];
    [self.window setRootViewController:termsPage];
}

- (void) tokenManagerMigrationInProgress {
    IGLog(@"AppDelegate tokenManagerMigrationInProgress");
    loginInProgress = NO;
    MigrateStatusController *migrationPage = [[MigrateStatusController alloc] init];
    [self.window setRootViewController:migrationPage];
}

- (void) startAutoSync {
    IGLog(@"AppDelegate startAutoSync");
    if([AppUtil readLocInfoPopupShownFlag]) {
        [[LocationManager sharedInstance] startLocationManager];
        [[SyncManager sharedInstance] decideAndStartAutoSync];
    } else {
        if(![CLLocationManager locationServicesEnabled] || !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||[CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            locInfoPopup = [[CustomInfoWithIconView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height) withIcon:@"icon_locationperm.png" withInfo:NSLocalizedString(@"LocInfoPopup", @"") withSubInfo:NSLocalizedString(@"LocSubinfoPopup", @"") isCloseable:YES];
            locInfoPopup.delegate = self;
            [self.window addSubview:locInfoPopup];
            [AppUtil writeLocInfoPopupShownFlag];
            [AppUtil writePeriodicLocInfoPopupIdleFlag];
        } else {
            [[LocationManager sharedInstance] startLocationManager];
            [[SyncManager sharedInstance] decideAndStartAutoSync];
        }
    }
}

- (void) stopAutoSync {
    //    [syncManager stopAutoSync];
}

- (void) customInfoWithIconViewDidDismiss {
    [[LocationManager sharedInstance] startLocationManager];
    [LocationManager sharedInstance].delegate = self;
    [[SyncManager sharedInstance] decideAndStartAutoSync];
}

- (void) locationPermissionGranted {
    //not used
}

- (void) locationPermissionError:(NSString *) errorMessage {
    //not used
}

- (void) locationPermissionDenied {
    [AppUtil resetPeriodicLocInfoPopupIdleFlag];
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

- (void) showCustomEntryPopup:(CustomEntryPopupView *) entryView {
    [self.window addSubview:entryView];
    [self.window bringSubviewToFront:entryView];
}

- (void) showMainLoading {
    [progress show:YES];
    [self.window bringSubviewToFront:progress];
}

- (void) hideMainLoading {
    [progress hide:YES];
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if(application.applicationState != UIApplicationStateActive) {
        //TODO [self application:application didFinishLaunchingWithOptions:notification.userInfo];
    }
}

- (void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    
    [self application:application didFinishLaunchingWithOptions:notification.userInfo];
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
    [MPush applicationDidReceiveRemoteNotification:userInfo];
    [self application:application didFinishLaunchingWithOptions:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
    [MPush applicationDidReceiveRemoteNotification:userInfo];
    [self application:application didFinishLaunchingWithOptions:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [MPush applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [[CurioNotificationManager shared] didRegisteredForNotifications:deviceToken];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /*
     if(self.uploadQueue && self.uploadQueue.session) {
     [self.uploadQueue.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
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
     [self triggerAutoSynchronization];
     }
     */
    
    [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
    }];
    
    [self triggerAutoSynchronization];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       if([[UploadQueue sharedInstance] remainingCount] > 0) {
                           completionHandler(UIBackgroundFetchResultNewData);
                       } else {
                           completionHandler(UIBackgroundFetchResultNoData);
                       }
                   });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    IGLog(@"AppDelegate applicationWillResignActive");
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    IGLog(@"AppDelegate applicationDidEnterBackground");
    /* auto contact sync kaldirildi
     if ([ContactSyncSDK automated]){
     [ContactSyncSDK sleep];
     }
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    IGLog(@"AppDelegate applicationWillEnterForeground");
    NSLog(@"AppDelegate applicationWillEnterForeground");
    activatedFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    IGLog(@"AppDelegate applicationDidBecomeActive");
    NSLog(@"AppDelegate applicationDidBecomeActive");
    //TODO contact sync ile aç
    /*
     if(session != nil) {
     [session checkLatestContactSyncStatus];
     }
     */
    
    NSLog(@".... %@", NSStringFromClass([self.window.rootViewController class]));
    if(activatedFromBackground && !loginInProgress && !self.session.loggedOutManually) {
        BOOL shouldContinue = YES;
        if([self.window.rootViewController isKindOfClass:[BaseViewController class]]) {
            shouldContinue = NO;
        } else if([self.window.rootViewController isKindOfClass:[MyNavigationController class]]){
            MyNavigationController *castedCtrl = (MyNavigationController *) self.window.rootViewController;
            if([[castedCtrl.viewControllers lastObject] isKindOfClass:[PostLoginSyncPrefController class]]) {
                shouldContinue = NO;
            }
            if([[castedCtrl.viewControllers lastObject] isKindOfClass:[OTPController class]]) {
                shouldContinue = NO;
            }
            if([[castedCtrl.viewControllers lastObject] isKindOfClass:[SignupController class]]) {
                shouldContinue = NO;
            }
        }
        if(shouldContinue) {
            IGLog(@"AppDelegate should relogin after from background");
            NSLog(@"AppDelegate should relogin after from background");
            if([ReachabilityManager isReachable]) {
                if([CacheUtil readRememberMeToken] != nil) {
                    IGLog(@"AppDelegate should relogin after from background RememberMeToken not null");
                    loginInProgress = YES;
                    [self addInitialBgImage];
                    [tokenManager requestToken];
                    [self showMainLoading];
                } else if([ReachabilityManager isReachableViaWWAN]) {
                    IGLog(@"AppDelegate should relogin after from background trying radius login");
                    loginInProgress = YES;
                    [self addInitialBgImage];
                    [tokenManager requestRadiusLogin];
                    [self showMainLoading];
                }
            }
        }
        /*
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
         */
        
        /*
         [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
         }];
         */
        
    } else {
        IGLog(@"AppDelegate activatedFromBackground && !backgroundReloginInProgress else'ine girdi");
        
        [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (!uploadTasks || [uploadTasks count] == 0) {
                [self removeAllMediaFiles];
            }
        }];
        // eğer backgrounddan gelmiyorsa bir sonraki auto sync bloğununun okunmasını engelleyen lock kaldırılıyor
        //        [SyncUtil unlockAutoSyncBlockInProgress];
    }
    
    //    [SyncUtil unlockAutoSyncBlockInProgress];
    
    if([SyncUtil readFirstTimeSyncFinishedFlag]) {
        [SyncUtil unlockAutoSyncBlockInProgress];
    }

    [self triggerAutoSynchronization];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging || [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    IGLog(@"AppDelegate applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CurioSDK shared] endSession];
    [SyncUtil unlockAutoSyncBlockInProgress];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [UploadQueue sharedInstance].backgroundSessionCompletionHandler = completionHandler;
}

void uncaughtExceptionHandler(NSException *exception) {
    //    NSLog(@"CRASH: %@", exception);
    //    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    [[UploadQueue sharedInstance] cancelAllUploads];
}

- (void) updateActionChosen {
}

- (void) updateCheckCompleted{
    if([CacheUtil readRememberMeToken] != nil) {
        [tokenManager requestToken];
        loginInProgress = YES;
        [self showMainLoading];
    } else {
        if(![AppUtil readFirstVisitOverFlag]) {
            //Uygulama silinip tekrar kurulursa eski badge degerini koruyor. Bunun engellenmesi icin eklendi
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [self triggerPreLogin];
        } else {
            [self triggerLogin];
        }
    }
}

- (void) logToFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"nslogs.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == NO_CONN_ALERT_TAG) {
        //        [self triggerLogout];
    }
}

-(void) removeAllMediaFiles
{
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSFileManager *fm = [NSFileManager defaultManager];
     NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentsDirectory error:nil];
     for (int i = 0; i< [dirContents count]; i++) {
     NSLog(@"%@",[dirContents objectAtIndex:i]);
     
     }*/
    
    NSFileManager  *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only sqlite files
    NSPredicate *fltrDepoUploadLeaks = [NSPredicate predicateWithFormat:@"self CONTAINS 'DEPO_UPLOAD_FILE'"];
    NSArray *leakFiles = [allFiles filteredArrayUsingPredicate:fltrDepoUploadLeaks];
    //NSPredicate *fltr = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:fltr3GP,fltrGIF,fltrJPEG,fltrMOV,fltrMp3,fltrMP4,fltrPNG, nil]];
    //NSArray *mediaFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    // use fast enumeration to iterate the array and delete the files
    for (NSString *file in leakFiles)
    {
        // NSError *error = nil;
        //[manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:sqliteFile] error:&error];
        //NSAssert(!error, @"Assertion: SQLite file deletion shall never throw an error.");
        NSString *path = file;
        NSString *leakFilePath = [documentsDirectory stringByAppendingPathComponent:path];
        [manager removeItemAtPath:leakFilePath error:nil];
        
    }
}

- (void) initAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [audioSession setCategory: AVAudioSessionCategoryPlayback error: nil];
    [audioSession setActive:YES error:nil];
    [self becomeFirstResponder];
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event {
    UIEventSubtype type = event.subtype;
    if (type == UIEventSubtypeRemoteControlNextTrack) {
        [session playNextAudioItem];
    }
    if (type == UIEventSubtypeRemoteControlPreviousTrack) {
        [session playPreviousAudioItem];
    }
    if (type == UIEventSubtypeRemoteControlStop) {
        [session stopAudioItem];
    }
    if (type == UIEventSubtypeRemoteControlPause) {
        [session pauseAudioItem];
    }
    if (type == UIEventSubtypeRemoteControlPlay) {
        [session playAudioItem];
    }
}

- (void)unregisteredFromNotificationServer:(NSDictionary *)responseDictionary {
}

- (void)customIDSent:(NSDictionary *)responseDictionary {
}

- (void) cancelRequestsWithTag:(int) tag {
    //    NSOperationQueue * temp = ASIHTTPRequest.sharedQueue;
    //    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations) {
    //        if(req.tag == tag) {
    //            [req cancel];
    //            [req setDelegate:nil];
    //        }
    //    }
}

- (void) cancelRequestsWithTags:(NSArray *) tags {
    //    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations) {
    //        if([tags containsObject:[NSNumber numberWithInteger:req.tag]]) {
    //            [req cancel];
    //            [req setDelegate:nil];
    //        }
    //    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if(![[url absoluteString] hasSuffix:@"cancel"]) {
            if ([[DBSession sharedSession] isLinked]) {
                NSLog(@"App linked successfully!");
                [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_LINK_SUCCESS_KEY object:nil userInfo:nil];
            }
        }
        return YES;
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:source annotation:annotation];
}

- (void) reachabilityDidChange {
    IGLog(@"AppDelegate reachabilityDidChange");
    
    if(noConnPopupShown) {
        [noConnAlert dismissWithClickedButtonIndex:0 animated:NO];
        noConnPopupShown = NO;
    }
    
    if(![ReachabilityManager isReachable]) {
        IGLog(@"AppDelegate reachabilityDidChange in ReachabilityManager:notReachable block");
        [[UploadQueue sharedInstance] cancelAllUploads];
        [self.base hideSyncInfoView];
    }
}

@end

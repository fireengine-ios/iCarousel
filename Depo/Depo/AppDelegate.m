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
#import "PhotoListController.h"

#import "MigrateStatusController.h"
#import "TermsController.h"

#import "Adjust.h"
#import "ACTReporter.h"
#import <SplunkMint/SplunkMint.h>
#import "ContactSyncSDK.h"

#import "ReachabilityManager.h"

#import "MMWormhole.h"

#import "UpdaterController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BgViewController.h"

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
@synthesize notificationAction;
@synthesize notificationActionUrl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [self.window setRootViewController:[BgViewController alloc]];
    
#ifdef LOG2FILE
    
    [self logToFiles];

#endif
    
    session = [[AppSession alloc] init];
    mapUtil = [[MapUtil alloc] init];
    wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:GROUP_NAME_SUITE_NSUSERDEFAULTS optionalDirectory:EXTENSION_WORMHOLE_DIR];

//mahir: loc update geldiğinden bg fetch cikarildi simdilik    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Adjust initialization
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:@"hlqdgtbmrdb9" environment:ADJEnvironmentProduction];
    [Adjust appDidLaunch:adjustConfig];
    
    //Google Conversion initialization
    [ACTConversionReporter reportWithConversionID:@"946883454" label:@"gJYdCOLv4wcQ_pbBwwM" value:@"0.00" isRepeatable:NO];
    
    //BugSense integration
//    [[Mint sharedInstance] initAndStartSession:@"13ceffcf"];

    //Curio integrationc
    [[CurioSDK shared] startSession:@"http://curio.turkcell.com.tr/api/v2" apiKey:@"cab314f33df2514764664e5544def586" trackingCode:@"KL2XNFIE" sessionTimeout:30 periodicDispatchEnabled:YES dispatchPeriod:5 maxCachedActivitiyCount:10 loggingEnabled:NO logLevel:0 registerForRemoteNotifications:YES notificationTypes:@"Sound,Badge,Alert" fetchLocationEnabled:NO maxValidLocationTimeInterval:600 delegate:self appLaunchOptions:launchOptions];

    [[CurioSDK shared] sendEvent:@"ApplicationStarted" eventValue:@"true"];

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
        UIAlertView *noConnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"ConnectionErrorWarning", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"SubmitButtonTitle", @"") otherButtonTitles:nil];
        noConnAlert.delegate = self;
        noConnAlert.tag = NO_CONN_ALERT_TAG;
        [noConnAlert show];
    } else {
        UpdaterController *updaterController = [UpdaterController initWithUpdateURL:UPDATER_SDK_URL delegate:self postProperties:NO];
        [self.window addSubview:updaterController];
        [updaterController getUpdateInformation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRequiredNotificationRaised) name:LOGIN_REQ_NOTIFICATION object:nil];
    
   
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initAudioSession];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void) assignNotificationActionByLaunchOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil && (launchOptions[@"action"] != nil || launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil)) {
        NSString *actionString = launchOptions[@"action"];
        if(actionString == nil && launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
            UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
            actionString = [localNotification userInfo][@"action"];
        }
        
        if ([actionString isEqualToString:@"main"]) {
            self.notificationAction = NotificationActionMain;
        } else if ([actionString isEqualToString:@"sync_settings"]) {
            self.notificationAction = NotificationActionSyncSettings;
        } else if ([actionString isEqualToString:@"floating_menu"]) {
            self.notificationAction = NotificationActionFloatingMenu;
        } else if ([actionString isEqualToString:@"packages"]) {
            self.notificationAction = NotificationActionPackages;
        } else if ([actionString isEqualToString:@"photos_videos"]) {
            self.notificationAction = NotificationActionPhotos;
        } else if([actionString hasPrefix:@"http"]) {
            self.notificationAction = NotificationActionWeb;
            self.notificationActionUrl = actionString;
        }
    }
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

    if (self.notificationAction > 0) {
        if (self.notificationAction == NotificationActionSyncSettings) {
            [self triggerSyncSettings];
        } else if (self.notificationAction == NotificationActionPackages) {
            [self triggerStorageSettings];
        } else if (self.notificationAction == NotificationActionFloatingMenu) {
            [self triggerFloatingMenu];
        } else if (self.notificationAction == NotificationActionPhotos) {
            [self triggerPhotosAndVideos];
        } else if (self.notificationAction == NotificationActionWeb){
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
    self.base = [[BaseViewController alloc] init];
    [self.window setRootViewController:base];
}

- (void) triggerPhotosAndVideos {
    MyViewController *photosController = [[PhotoListController alloc] init];
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
    
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
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

    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations) {
        [req cancel];
        [req setDelegate:nil];
    }

    [self.session stopAudioItem];
    [self.session cleanoutAfterLogout];
    [CacheUtil resetRememberMeToken];
    [[UploadQueue sharedInstance] cancelAllUploads];

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
    [[LocationManager sharedInstance] startLocationManager];
    [[SyncManager sharedInstance] decideAndStartAutoSync];
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
    [self application:application didFinishLaunchingWithOptions:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
    [self application:application didFinishLaunchingWithOptions:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
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
    if(session != nil) {
        [session checkLatestContactSyncStatus];
    }
    
    if(activatedFromBackground) {
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
        
    } else {
        
        [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (!uploadTasks || [uploadTasks count] == 0) {
                [self removeAllMediaFiles];
            }
        }];
        // eğer backgrounddan gelmiyorsa bir sonraki auto sync bloğununun okunmasını engelleyen lock kaldırılıyor
//        [SyncUtil unlockAutoSyncBlockInProgress];
    }
    
    [SyncUtil unlockAutoSyncBlockInProgress];

    [self triggerAutoSynchronization];

    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging || [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
        [self triggerLogout];
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

@end

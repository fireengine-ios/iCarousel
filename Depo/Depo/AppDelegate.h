//
//  AppDelegate.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSession.h"
#import "TokenManager.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"
#import "UploadQueue.h"
#import "UpdaterControllerDelegate.h"
#import "CurioSDK.h"

@class CustomAlertView;
@class CustomConfirmView;
@class CustomEntryPopupView;
@class BaseViewController;
@class MyNavigationController;
@class MyViewController;
@class MapUtil;
@class MMWormhole;

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, TokenManagerDelegate, UpdaterControllerDelegate, UIAlertViewDelegate, CurioSDKDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppSession *session;
@property (strong, nonatomic) BaseViewController *base;
@property (strong, nonatomic) TokenManager *tokenManager;
@property (strong, nonatomic) MapUtil *mapUtil;
@property (strong, nonatomic) MBProgressHUD *progress;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic) NotificationAction notificationAction;
@property (nonatomic) NSString *notificationActionUrl;
@property (nonatomic) BOOL activatedFromBackground;

- (void) showCustomAlert:(CustomAlertView *) alertView;
- (void) showCustomConfirm:(CustomConfirmView *) alertView;
- (void) showCustomEntryPopup:(CustomEntryPopupView *) entryView;
- (void) triggerPostTermsAndMigration;
- (void) triggerLogin;
- (void) triggerPostLogin;
- (void) triggerHome;
- (void) triggerLogout;
- (void) startAutoSync;
- (void) stopAutoSync;
- (void) startOpeningPage;
- (void) removeAllMediaFiles;
- (void) cancelRequestsWithTag:(int) tag;
- (void) cancelRequestsWithTags:(NSArray *) tags;
- (BOOL) isTurkcell;

@end

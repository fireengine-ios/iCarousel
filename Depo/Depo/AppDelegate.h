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

@class CustomAlertView;
@class CustomConfirmView;
@class BaseViewController;
@class MyNavigationController;
@class MyViewController;
@class MapUtil;

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, TokenManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppSession *session;
@property (strong, nonatomic) BaseViewController *base;
@property (strong, nonatomic) TokenManager *tokenManager;
@property (strong, nonatomic) MapUtil *mapUtil;
@property (strong, nonatomic) MBProgressHUD *progress;
@property (strong, nonatomic) SyncManager *syncManager;

- (void) showCustomAlert:(CustomAlertView *) alertView;
- (void) showCustomConfirm:(CustomConfirmView *) alertView;
- (void) triggerLogin;
- (void) triggerPostLogin;
- (void) triggerHome;
- (void) triggerLogout;

@end

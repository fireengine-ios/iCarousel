//
//  AppDelegate.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSession.h"

@class CustomAlertView;
@class CustomConfirmView;
@class BaseViewController;
@class MyNavigationController;
@class MyViewController;

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppSession *session;
@property (strong, nonatomic) BaseViewController *base;

- (void) showCustomAlert:(CustomAlertView *) alertView;
- (void) showCustomConfirm:(CustomConfirmView *) alertView;

@end

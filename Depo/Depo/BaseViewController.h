//
//  BaseViewController.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyNavigationController.h"
#import "SlidingMenu.h"
#import "MyViewController.h"
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController <SlidingMenuDelegate, SlidingMenuCloseDelegate, MyViewDelegate> {
}

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) SlidingMenu *menu;
@property (nonatomic, strong) MBProgressHUD *baseProgress;
@property (nonatomic) BOOL menuOpen;

- (void) showBaseLoading;
- (void) hideBaseLoading;
- (id)initWithRootViewController:(MyViewController *) rootViewController;

@end

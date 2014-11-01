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
#import "FloatingAddButton.h"
#import "FloatingAddMenu.h"

@interface BaseViewController : UIViewController <SlidingMenuDelegate, SlidingMenuCloseDelegate, MyViewDelegate, FloatingAddButtonDelegate, FloatingAddDelegate>

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) SlidingMenu *menu;
@property (nonatomic, strong) MBProgressHUD *baseProgress;
@property (nonatomic, strong) FloatingAddButton *addButton;
@property (nonatomic, strong) FloatingAddMenu *addMenu;
@property (nonatomic) BOOL menuOpen;

- (void) showBaseLoading;
- (void) hideBaseLoading;
- (id)initWithRootViewController:(MyViewController *) rootViewController;
- (void) presentAddButtonWithList:(NSArray *) _addTypeList;
- (void) dismissAddButton;
- (void) showConfirmDelete;
- (void) showSort;
- (void) showSelect;
- (void) immediateShowAddButton;
- (void) immediateHideAddButton;

@end

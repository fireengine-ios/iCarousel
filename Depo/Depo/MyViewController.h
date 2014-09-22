//
//  MyViewController.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyNavigationController.h"
#import "MBProgressHUD.h"

@protocol MyViewDelegate <NSObject>
- (void) shouldToggleMenu;
- (void) shouldTriggerLoggedInPage;
- (void) shouldTriggerLogin;
@end

@interface MyViewController : UIViewController {
    NSMutableDictionary *filterDictionary;
}

@property (nonatomic, strong) id<MyViewDelegate> myDelegate;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) MBProgressHUD *progress;
@property (nonatomic, strong) NSArray *refPageList;
@property (nonatomic, strong) NSString *searchQueryRef;
@property (nonatomic) int navBarHeight;
@property (nonatomic) int topIndex;
@property (nonatomic) int bottomIndex;
@property (nonatomic) int pageOffset;
@property (nonatomic) int currentPageCount;
@property (nonatomic) int tableUpdateCounter;
@property (nonatomic) int totalPageCount;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) BOOL isLoadingEnabled;
@property (nonatomic) BOOL resetResultTable;

- (void) showLoading;
- (void) hideLoading;
- (void) showErrorAlertWithMessage:(NSString *) errMessage;
- (void) showInfoAlertWithMessage:(NSString *) infoMessage;
- (void) increaseTableUpdateCounter;
- (void) resetTableUpdateCounter;
- (void) resetPageOffset;
- (void) triggerMenuLoginWithinPage;

@end

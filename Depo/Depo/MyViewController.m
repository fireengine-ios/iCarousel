//
//  MyViewController.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "MyViewController.h"
#import "CustomButton.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppConstants.h"
#import "CustomAlertView.h"
#import "CustomConfirmView.h"

@interface MyViewController ()

@end

@implementation MyViewController

@synthesize nav;
@synthesize myDelegate;
@synthesize progress;
@synthesize navBarHeight;
@synthesize topIndex;
@synthesize bottomIndex;
@synthesize refPageList;
@synthesize resetResultTable;
@synthesize pageOffset;
@synthesize currentPageCount;
@synthesize isLoadingMore;
@synthesize isLoadingEnabled;
@synthesize tableUpdateCounter;
@synthesize totalPageCount;
@synthesize searchQueryRef;

- (id)init {
    self = [super init];
    if (self) {
        if(IS_BELOW_7) {
            navBarHeight = 44;
        } else {
            navBarHeight = 64;
        }

        if(IS_BELOW_7) {
            topIndex = 0;
            bottomIndex = 44;
        } else {
            topIndex = 0;
            bottomIndex = 60;
        }
        
        pageOffset = 1;
        tableUpdateCounter = 0;

        self.view.backgroundColor = [UIColor whiteColor];

        CustomButton *listButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 20, 12) withImageName:@"menu_icon.png"];
        [listButton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        self.navigationItem.leftBarButtonItem = leftButton;
        
        progress = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        progress.opacity = 0.4f;
        [self.view addSubview:progress];
    }
    return self;
}

- (void) showLoading {
    [progress show:YES];
    [self.view bringSubviewToFront:progress];
    /*
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [loadingView startAnimation];
     */
}

- (void) hideLoading {
    [progress hide:YES];
    /*
    loadingView.hidden = YES;
    [loadingView stopAnimation];
     */
}

- (void) menuClicked {
    [myDelegate shouldToggleMenu];
}

- (void) showErrorAlertWithMessage:(NSString *) errMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:@"Hata" withMessage:errMessage withModalType:ModalTypeError];
    [APPDELEGATE showCustomAlert:alert];
}

- (void) showInfoAlertWithMessage:(NSString *) infoMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:@"Bilgi" withMessage:infoMessage withModalType:ModalTypeSuccess];
    [APPDELEGATE showCustomAlert:alert];
}

- (void) increaseTableUpdateCounter {
    self.tableUpdateCounter += 1;
}

- (void) resetTableUpdateCounter {
    self.tableUpdateCounter = 0;
}

- (void) resetPageOffset {
    self.pageOffset = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) triggerMenuLoginWithinPage {
    [myDelegate shouldTriggerLogin];
}

@end

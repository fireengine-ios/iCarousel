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
#import "BaseViewController.h"
#import "MapUtil.h"
#import "CurioSDK.h"
#import "MPush.h"

@interface MyViewController ()

@end

@implementation MyViewController

@synthesize nav;
@synthesize myDelegate;
@synthesize progress;
@synthesize navBarHeight;
@synthesize topIndex;
@synthesize bottomIndex;
@synthesize moreMenuView;
@synthesize processView;
@synthesize refPageList;
@synthesize resetResultTable;
@synthesize pageOffset;
@synthesize currentPageCount;
@synthesize isLoadingMore;
@synthesize isLoadingEnabled;
@synthesize tableUpdateCounter;
@synthesize totalPageCount;
@synthesize searchQueryRef;
@synthesize scrollingLastContentOffset;
@synthesize deleteType;

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
            bottomIndex = 64;
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
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:errMessage withModalType:ModalTypeError];
    [APPDELEGATE showCustomAlert:alert];
}

- (void) showInfoAlertWithMessage:(NSString *) infoMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withMessage:infoMessage withModalType:ModalTypeSuccess];
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
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(self.class)];
    if(addTypesForController != nil) {
        [APPDELEGATE.base presentAddButtonWithList:addTypesForController];
    } else {
        [APPDELEGATE.base dismissAddButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) triggerMenuLoginWithinPage {
    [myDelegate shouldTriggerLogin];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *curioValForController = [APPDELEGATE.mapUtil readCurioValueByController:NSStringFromClass(self.class)];
    if(curioValForController != nil) {
        [[CurioSDK shared] startScreen:[self class] title:curioValForController path:curioValForController];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self popProgressViewSimply];
    [[CurioSDK shared] endScreen:[self class]];
}

- (void) presentMoreMenuWithList:(NSArray *) itemList {
    if(moreMenuView) {
        [self dismissMoreMenu];
    } else {
        moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height) withList:itemList];
        moreMenuView.delegate = self;
        [self.view addSubview:moreMenuView];
        [self.view bringSubviewToFront:moreMenuView];
    }
}

- (void) presentMoreMenuWithList:(NSArray *) itemList withFileFolder:(MetaFile *) fileFolder {
    if(moreMenuView) {
        [self dismissMoreMenu];
    } else {
        moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height) withList:itemList withFileFolder:fileFolder];
        moreMenuView.delegate = self;
        [self.view addSubview:moreMenuView];
        [self.view bringSubviewToFront:moreMenuView];
    }
}

- (void) dismissMoreMenu {
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
        moreMenuView = nil;
    }
}

- (void) moreMenuDidDismiss {
    [self performSelector:@selector(postMoreMenuDismiss) withObject:nil afterDelay:0.1f];
}

- (void) postMoreMenuDismiss {
    moreMenuView = nil;
}

- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg {
    if(processView) {
        [processView removeFromSuperview];
    }
    
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) withProcessMessage:progressMsg withFinalMessage:successMsg withFailMessage:failMsg];
    processView.delegate = self;
    [self.view addSubview:processView];
    [self.view bringSubviewToFront:processView];

    [processView startLoading];
    [APPDELEGATE.base dismissAddButton];
}

- (void) proceedSuccessForProgressView {
    if(processView) {
        [processView showMessageForSuccess];
    }
}

- (void) proceedSuccessForProgressViewWithAddButtonKey:(NSString *) buttonKey {
    if(processView) {
        [processView showMessageForSuccessWithPostButtonKey:buttonKey];
    }
}

- (void) proceedFailureForProgressView {
    if(processView) {
        [processView showMessageForFailure];
    }
}

- (void) proceedFailureForProgressViewWithAddButtonKey:(NSString *) buttonKey {
    if(processView) {
        [processView showMessageForFailureWithPostButtonKey:buttonKey];
    }
}

#pragma mark ProcessFooterDelegate methods

- (void) processFooterShouldDismissWithButtonKey:(NSString *)postButtonKeyVal {
    if(postButtonKeyVal == nil) {
        [self performSelector:@selector(showAddButtonImmediately) withObject:nil];
    } else {
        [self performSelector:@selector(showAddButtonImmediately:) withObject:postButtonKeyVal];
    }
}

- (void) showAddButtonImmediately {
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(self.class)];
    if(addTypesForController != nil) {
        [APPDELEGATE.base immediateShowAddButton];
    }
}

- (void) showAddButtonImmediately:(NSString *) key {
    if([NSStringFromClass([[self.nav topViewController] class]) isEqualToString:@"PhotoListController"]) {
        NSArray *addTypesForKey = [APPDELEGATE.mapUtil readAddTypesByController:key];
        if(addTypesForKey != nil) {
            [APPDELEGATE.base immediateShowAddButton];
            [APPDELEGATE.base modifyAddButtonWithList:addTypesForKey];
        }
    }
}

- (void) popProgressViewSimply {
    if(processView) {
        [processView removeFromSuperview];
    }
}

- (void) popProgressView {
    if(processView) {
        [processView removeFromSuperview];
    }
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass([[self.nav topViewController] class])];
    if(addTypesForController != nil) {
        [APPDELEGATE.base presentAddButtonWithList:addTypesForController];
    }
}

- (void) newFolderModalDidTriggerNewFolderWithName:(NSString *)folderName {
}

- (void) cameraCapturaModalDidCancel {
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filepath withName:(NSString *)fileName {
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
}

- (void) sortDidChange {
}

- (void) changeToSelectedStatus {
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
}

- (void) folderDetailShouldRename:(NSString *)newNameVal {
}

- (void) fileDetailShouldRename:(NSString *)newNameVal {
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
}

#pragma mark MoreMenuDelegate methods

- (void) moreMenuDidSelectDelete {
    [MPush hitTag:@"delete_button_clicked"];
}

- (void) moreMenuDidSelectFav {
    [MPush hitTag:@"add_to_favorites_button_clicked"];
}

- (void) moreMenuDidSelectUnfav {
}

- (void) moreMenuDidSelectShare {
    [MPush hitTag:@"share_button_clicked"];
    [MPush hitEvent:@"share_button_clicked"];
}

- (void) moreMenuDidSelectDownloadImage {
}

- (void) moreMenuDidSelectSortWithList {
}

#pragma mark AlbumModalDelegate methods

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
}

#pragma mark AlbumDetailDelegate methods

- (void)albumDetailShouldRenameWithName:(NSString *)newName {
}



- (void)fadeIn:(UIView *)view duration:(float)duration {
    view.alpha = 0;
    view.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) { }];
}

- (void)fadeOut:(UIView *)view duration:(float)duration {
    view.alpha = 1;
    view.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

@end

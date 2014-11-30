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
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) presentMoreMenuWithList:(NSArray *) itemList {
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
    }

    moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height) withList:itemList];
    moreMenuView.delegate = self;
    [self.view addSubview:moreMenuView];
    [self.view bringSubviewToFront:moreMenuView];
}

- (void) presentMoreMenuWithList:(NSArray *) itemList withFileFolder:(MetaFile *) fileFolder {
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
    }
    
    moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height) withList:itemList withFileFolder:fileFolder];
    moreMenuView.delegate = self;
    [self.view addSubview:moreMenuView];
    [self.view bringSubviewToFront:moreMenuView];
}

- (void) dismissMoreMenu {
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
    }
}

- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg {
    if(processView) {
        [processView removeFromSuperview];
    }
    
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) withProcessMessage:progressMsg withFinalMessage:successMsg withFailMessage:failMsg];
    [self.view addSubview:processView];
    [self.view bringSubviewToFront:processView];

    [processView startLoading];
    [APPDELEGATE.base dismissAddButton];
}

- (void) proceedSuccessForProgressView {
    if(processView) {
        [processView showMessageForSuccess];
    }
    [self performSelector:@selector(showAddButtonImmediately) withObject:nil afterDelay:1.2f];
}

- (void) proceedFailureForProgressView {
    if(processView) {
        [processView showMessageForFailure];
    }
    [self performSelector:@selector(showAddButtonImmediately) withObject:nil afterDelay:1.2f];
}

- (void) showAddButtonImmediately {
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(self.class)];
    if(addTypesForController != nil) {
        [APPDELEGATE.base immediateShowAddButton];
    }
}

- (void) popProgressView {
    if(processView) {
        [processView removeFromSuperview];
    }
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(self.class)];
    if(addTypesForController != nil) {
        [APPDELEGATE.base presentAddButtonWithList:addTypesForController];
    }
}

- (void) newFolderModalDidTriggerNewFolderWithName:(NSString *)folderName {
    NSLog(@"At MyView newFolderModalDidTriggerNewFolderWithName");
}

- (void) cameraCapturaModalDidCancel {
    NSLog(@"At MyView cameraCapturaModalDidCancel");
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filepath {
    NSLog(@"At MyView cameraCapturaModalDidCaptureAndStoreImageToPath for filePath:%@", filepath);
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    NSLog(@"At MyView photoModalDidTriggerUploadForUrls");
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
    NSLog(@"At MyView newAlbumModalDidTriggerNewAlbumWithName");
}

- (void) sortDidChange {
    NSLog(@"At MyView sortDidChange");
}

- (void) changeToSelectedStatus {
    NSLog(@"At MyView changeToSelectedStatus");
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    NSLog(@"At MyView moveListModalDidSelectFolder");
}

- (void) folderDetailShouldRename:(NSString *)newNameVal {
    NSLog(@"At MyView folderDetailShouldRename");
}

- (void) fileDetailShouldRename:(NSString *)newNameVal {
    NSLog(@"At MyView fileDetailShouldRename");
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
    NSLog(@"At MyView confirmDeleteDidCancel");
}

- (void) confirmDeleteDidConfirm {
    NSLog(@"At MyView confirmDeleteDidConfirm");
}

#pragma mark MoreMenuDelegate methods

- (void) moreMenuDidSelectDelete {
    NSLog(@"At MyView moreMenuDidSelectDelete");
}

- (void) moreMenuDidSelectFav {
    NSLog(@"At MyView moreMenuDidSelectFav");
}

- (void) moreMenuDidSelectUnfav {
    NSLog(@"At MyView moreMenuDidSelectUnfav");
}

- (void) moreMenuDidSelectShare {
    NSLog(@"At MyView moreMenuDidSelectShare");
}

- (void) moreMenuDidSelectDownloadImage {
    NSLog(@"At MyView moreMenuDidSelectDownloadImage");
}

- (void) moreMenuDidSelectSortWithList {
    NSLog(@"At MyView moreMenuDidSelectSortWithList");
}

#pragma mark AlbumModalDelegate methods

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    NSLog(@"At MyView albumModalDidSelectAlbum");
}

#pragma mark AlbumDetailDelegate methods

- (void)albumDetailShouldRenameWithName:(NSString *)newName {
    NSLog(@"At MyView albumDetailShouldRenameWithName");
}

@end

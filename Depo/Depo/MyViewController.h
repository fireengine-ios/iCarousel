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
#import "MoreMenuView.h"
#import "ProcessFooterView.h"
#import "NewFolderModalController.h"
#import "CameraCaptureModalController.h"
#import "PhotoListModalController.h"
#import "NewAlbumModalController.h"
#import "SortModalController.h"
#import "MoveListModalController.h"
#import "FolderDetailModalController.h"
#import "ConfirmDeleteModalController.h"
#import "FileDetailModalController.h"
#import "PhotoAlbumListModalController.h"
#import "AlbumDetailModalController.h"
#import "CacheUtil.h"

@protocol MyViewDelegate <NSObject>
- (void) shouldToggleMenu;
- (void) shouldTriggerLoggedInPage;
- (void) shouldTriggerLogin;
@end

@interface MyViewController : UIViewController <NewFolderDelegate, CameraCapturaModalDelegate, PhotoModalDelegate, NewAlbumDelegate, SortModalDelegate, MoveListModalProtocol, FolderDetailDelegate, FileDetailDelegate, MoreMenuDelegate, ConfirmDeleteDelegate, AlbumModalDelete, AlbumDetailDelegate, ProcessFooterDelegate> {
    NSMutableDictionary *filterDictionary;
}

@property (nonatomic, weak) id<MyViewDelegate> myDelegate;
@property (nonatomic, weak) MyNavigationController *nav;
@property (nonatomic, strong) MBProgressHUD *progress;
@property (nonatomic, strong) NSArray *refPageList;
@property (nonatomic, strong) NSString *searchQueryRef;
@property (nonatomic, strong) MoreMenuView *moreMenuView;
@property (nonatomic, strong) ProcessFooterView *processView;
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
@property (nonatomic) DeleteType deleteType;
@property (nonatomic, assign) CGFloat scrollingLastContentOffset;

- (void) showLoading;
- (void) hideLoading;
- (void) showErrorAlertWithMessage:(NSString *) errMessage;
- (void) showInfoAlertWithMessage:(NSString *) infoMessage;
- (void) increaseTableUpdateCounter;
- (void) resetTableUpdateCounter;
- (void) resetPageOffset;
- (void) triggerMenuLoginWithinPage;
- (void) presentMoreMenuWithList:(NSArray *) itemList;
- (void) presentMoreMenuWithList:(NSArray *) itemList withFileFolder:(MetaFile *) fileFolder;
- (void) dismissMoreMenu;
- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg;
- (void) proceedSuccessForProgressView;
- (void) proceedSuccessForProgressViewWithAddButtonKey:(NSString *) buttonKey;
- (void) proceedFailureForProgressView;
- (void) proceedFailureForProgressViewWithAddButtonKey:(NSString *) buttonKey;
- (void) popProgressView;
- (void) popProgressViewSimply;
- (void) showAddButtonImmediately;
- (void) fadeIn:(UIView *)view duration:(float)duration;
- (void) fadeOut:(UIView *)view duration:(float)duration;

@end

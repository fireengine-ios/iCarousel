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
#import "PhotoAlbum.h"
#import "ShareLinkDao.h"
#import "SyncInfoHeaderView.h"
#import "CustomConfirmView.h"
#import "AccurateLocationManager.h"
#import "DownloadManager.h"
#import "ProcessFooterView.h"

@interface BaseViewController : UIViewController <SlidingMenuDelegate, SlidingMenuCloseDelegate, MyViewDelegate, FloatingAddButtonDelegate, FloatingAddDelegate, UIGestureRecognizerDelegate, CustomConfirmDelegate, AccurateLocationManagerDelegate, DownloadManagerDelegate, ProcessFooterDelegate> {
    NSMutableArray *downloadManagers;
    ProcessFooterView *downloadingProcessView;
}

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) SyncInfoHeaderView *syncInfoView;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) SlidingMenu *menu;
@property (nonatomic, strong) MBProgressHUD *baseProgress;
@property (nonatomic, strong) FloatingAddButton *addButton;
@property (nonatomic, strong) FloatingAddMenu *addMenu;
@property (nonatomic, strong) ShareLinkDao *shareDao;
//@property (nonatomic, strong) MyViewController *rootViewController;
@property (nonatomic) BOOL menuOpen;
@property (nonatomic) BOOL menuLocked;
@property (nonatomic) BOOL popupCheckDone;
@property (nonatomic) BOOL isVideosAlbum;

- (void) showBaseLoading;
- (void) hideBaseLoading;
- (id) initWithRootViewController:(MyViewController *) _rootViewController;
- (void) presentAddButtonWithList:(NSArray *) _addTypeList;
- (void) modifyAddButtonWithList:(NSArray *) addTypeList;
- (void) dismissAddButton;
//- (void) showConfirmDelete;
- (void) showConfirmDelete:(NSString*) message;
//TakingBack RemoveFromAlbum
- (void) showConfirmRemove;
//- (void) showSort;
//- (void) showSortWithList:(NSArray *) sortTypeList;
//- (void) showSelect;
//- (void) showMoveFolders;
//- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid;
//- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid withProhibitedFolderList:(NSArray *) prohibitedList;
//- (void) showPhotoAlbums;
//- (void) showRecentActivities;
//- (void) showFolderDetailForFolder:(MetaFile *) folder;
//- (void) showFileDetailForFile:(MetaFile *) file;
//- (void) showAlbumDetailForAlbum:(PhotoAlbum *) album;
- (void) immediateShowAddButton;
- (void) immediateHideAddButton;
- (BOOL) isAddButtonHidden;
- (void) checkAndShowAddButton;

//- (void) triggerShareForFiles:(NSArray *) fileUuidList;
//- (void) triggerShareForFileObjects:(NSArray *) fileList;

- (void) lockMenu;
- (void) unlockMenu;

- (void) showSyncInfoView;
- (void) hideSyncInfoView;

- (void) didTriggerHome;
- (void) triggerInnerSearch;


#pragma mark - Downloading to Photos

-(void)createAlbum:(PhotoAlbum*)album withFiles:(NSArray *)files loadingMessage:(NSString *)message
    successMessage:(NSString *)successMessage failMessage:(NSString *)failMessage;
-(void)createAlbums:(NSArray *)albums loadingMessage:(NSString *)message
     successMessage:(NSString *)successMessage failMessage:(NSString *)failMessage;

-(void)downloadFilesToCameraRoll:(NSArray *)files
                  loadingMessage:(NSString *)loadingMessage
                  successMessage:(NSString *)successMessage
                     failMessage:(NSString *)failMessage;
@end

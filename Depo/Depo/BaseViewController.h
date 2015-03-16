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

@interface BaseViewController : UIViewController <SlidingMenuDelegate, SlidingMenuCloseDelegate, MyViewDelegate, FloatingAddButtonDelegate, FloatingAddDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) SlidingMenu *menu;
@property (nonatomic, strong) MBProgressHUD *baseProgress;
@property (nonatomic, strong) FloatingAddButton *addButton;
@property (nonatomic, strong) FloatingAddMenu *addMenu;
@property (nonatomic, strong) ShareLinkDao *shareDao;
@property (nonatomic) BOOL menuOpen;
@property (nonatomic) BOOL menuLocked;

- (void) showBaseLoading;
- (void) hideBaseLoading;
- (id)initWithRootViewController:(MyViewController *) rootViewController;
- (void) presentAddButtonWithList:(NSArray *) _addTypeList;
- (void) modifyAddButtonWithList:(NSArray *) addTypeList;
- (void) dismissAddButton;
- (void) showConfirmDelete;
- (void) showSort;
- (void) showSortWithList:(NSArray *) sortTypeList;
- (void) showSelect;
- (void) showMoveFolders;
- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid;
- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid withProhibitedFolderList:(NSArray *) prohibitedList;
- (void) showPhotoAlbums;
- (void) showRecentActivities;
- (void) showFolderDetailForFolder:(MetaFile *) folder;
- (void) showFileDetailForFile:(MetaFile *) file;
- (void) showAlbumDetailForAlbum:(PhotoAlbum *) album;
- (void) immediateShowAddButton;
- (void) immediateHideAddButton;
- (BOOL) isAddButtonHidden;
- (void) checkAndShowAddButton;

- (void) triggerShareForFiles:(NSArray *) fileUuidList;

- (void) lockMenu;
- (void) unlockMenu;

@end

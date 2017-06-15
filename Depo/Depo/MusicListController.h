//
//  MusicListController.h
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "FavoriteDao.h"
#import "DeleteDao.h"
#import "MoveDao.h"
#import "ShareLinkDao.h"
#import "AbstractFileFolderCell.h"
#import "FooterActionsMenuView.h"
#import "MusicPreviewController.h"
#import "MainSearchTextfield.h"

@interface MusicListController : MyViewController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate, FooterActionsDelegate, MusicPreviewDelegate, UITextFieldDelegate> {
    ElasticSearchDao *elasticSearchDao;
    ElasticSearchDao *loadMoreDao;
    FavoriteDao *favoriteDao;
    DeleteDao *deleteDao;
    MoveDao *moveDao;
    ShareLinkDao *shareDao;

    MetaFile *fileSelectedRef;
    
    CustomButton *moreButton;

    UIBarButtonItem *previousButtonRef;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) UITableView *musicTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *selectedMusicList;
@property (nonatomic, strong) NSMutableDictionary *musicDict;
@property (nonatomic, strong) NSArray *musicDictKeys;
@property (nonatomic, strong) NSArray *musicListRef;
@property (nonatomic, strong) NSArray *uuidsToBeDeleted;
@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;
@property (nonatomic, strong) MainSearchTextfield *searchField;

@end

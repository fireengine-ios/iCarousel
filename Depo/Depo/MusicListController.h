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
#import "AbstractFileFolderCell.h"
#import "FooterActionsMenuView.h"

@interface MusicListController : MyViewController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate, FooterActionsDelegate> {
    ElasticSearchDao *elasticSearchDao;
    FavoriteDao *favoriteDao;
    DeleteDao *deleteDao;
    MoveDao *moveDao;

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
@property (nonatomic, strong) NSMutableArray *musicDictKeys;
@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;

@end

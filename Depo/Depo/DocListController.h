//
//  DocListController.h
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "FavoriteDao.h"
#import "DeleteDao.h"
#import "MoveDao.h"
#import "AbstractFileFolderCell.h"
#import "FooterActionsMenuView.h"
#import "ShareLinkDao.h"

@interface DocListController : MyViewController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate, FooterActionsDelegate> {
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

@property (nonatomic, strong) UITableView *docTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *docList;
@property (nonatomic, strong) NSMutableArray *selectedDocList;
@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;

@end

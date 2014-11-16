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

@interface DocListController : MyViewController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate> {
    ElasticSearchDao *elasticSearchDao;
    FavoriteDao *favoriteDao;
    DeleteDao *deleteDao;
    MoveDao *moveDao;
    
    CustomButton *moreButton;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) UITableView *docTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *docList;
@property (nonatomic, strong) NSMutableArray *selectedDocList;

@end

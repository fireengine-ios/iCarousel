//
//  SearchMoreModalController.h
//  Depo
//
//  Created by RDC on 03.12.14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SearchDao.h"
#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "ShareLinkDao.h"
#import "MoveDao.h"
#import "ConfirmDeleteModalController.h"
#import "MoveListModalController.h"
#import "CustomConfirmView.h"

@interface SearchMoreModalController : MyModalController <UITableViewDelegate, UITableViewDataSource, ConfirmDeleteDelegate, MoveListModalProtocol, CustomConfirmDelegate> {
    UITableView *searchResultsTable;
    SearchDao *searchDao;
    int listOffset;
    int tableUpdateCounter;
    NSMutableArray *fileList;
    int searchListType;
    NSString *searchText;
    int fileCount;
    BOOL isLoading;
    
    SearchDao *loadMoreDao;
    DeleteDao *deleteDao;
    DeleteDao *folderDeleteDao;
    FavoriteDao *favoriteDao;
    FavoriteDao *folderFavDao;
    ShareLinkDao *shareDao;
    MoveDao *moveDao;

    MetaFile *fileSelectedRef;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (id) initWithSearchText:(NSString *)srchTxt andSearchListType:(int)srchLstTyp andFileCount:(int)flCnt;

@end

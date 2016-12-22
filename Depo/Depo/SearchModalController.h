//
//  SearchModalController.h
//  Depo
//
//  Created by NCO on 18/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SearchTextField.h"
#import "RecentSearchesTableView.h"
#import "SearchDao.h"
#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "MoveDao.h"
#import "ShareLinkDao.h"
#import "ConfirmDeleteModalController.h"
#import "MoveListModalController.h"
#import "PhotoAlbumController.h"
#import "CustomConfirmView.h"
#import "SuggestDao.h"

@interface SearchModalController : MyModalController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ConfirmDeleteDelegate, MoveListModalProtocol, PhotoAlbumDelegate, CustomConfirmDelegate> {
    UIView *searchFieldContainer;
    SearchTextField *searchField;
    RecentSearchesTableView *recentSearchesTableView;
    UITableView *searchResultsTable;
    
    SearchDao *searchDao;
    SuggestDao *suggestionsDao;
    DeleteDao *deleteDao;
    DeleteDao *folderDeleteDao;
    FavoriteDao *favoriteDao;
    FavoriteDao *folderFavDao;
    MoveDao *moveDao;
    ShareLinkDao *shareDao;
    
    int listOffset;
    int tableUpdateCounter;
    
    NSMutableArray *fileList;
    NSMutableArray *docList;
    NSMutableArray *photoVideoList;
    NSMutableArray *musicList;
    NSString *currentSearchText;
    BOOL animateSearchArea;
    float tableHeight;
    
    MetaFile *fileSelectedRef;
}

@property (nonatomic) DeleteType deleteType;

- (void)startSearch:(NSString *)searchText;

@end

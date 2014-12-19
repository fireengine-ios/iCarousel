//
//  FavouriteListController.h
//  Depo
//
//  Created by NCO on 07/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FavoriteDao.h"


@interface FavouriteListController : MyViewController <UITableViewDelegate, UITableViewDataSource>
{
    FavoriteDao *favoriteDao;
    int listOffset;
    BOOL isLoading;
    FavoriteDao *loadMoreDao;
    BOOL isFirstLoad;
}

@property (nonatomic, strong) UITableView *fileTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *fileList;

@end

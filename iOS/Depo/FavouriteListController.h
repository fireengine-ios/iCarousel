//
//  FavouriteListController.h
//  Depo
//
//  Created by NCO on 07/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FavoriteDao.h"
#import "CurrentMusicListModalController.h"
#import "CurrentDocumentListModalController.h"
#import "CurrentPhotoListModalController.h"

@interface FavouriteListController : MyViewController <UITableViewDelegate, UITableViewDataSource, CurrentMusicListModalDelegate, CurrentDocumentListModalDelegate, CurrentPhotoListModalDelegate> {
    FavoriteDao *listDao;
    FavoriteDao *favoriteDao;
    int listOffset;
    BOOL isLoading;
    FavoriteDao *loadMoreDao;
    BOOL isFirstLoad;
    BOOL shouldPreventLoadWhenAppeared;
}

@property (nonatomic, strong) UITableView *fileTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *favUnfavFileUuidRef;
@property (nonatomic) BOOL favUnfavFileFlagRef;

@end

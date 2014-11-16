//
//  PhotoListController.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "MetaFile.h"
#import "PhotoHeaderSegmentView.h"
#import "SquareImageView.h"
#import "AlbumListDao.h"
#import "AddAlbumDao.h"
#import "DeleteDao.h"
#import "DeleteAlbumsDao.h"
#import "AlbumAddPhotosDao.h"
#import "CustomButton.h"
#import "FooterActionsMenuView.h"

@interface PhotoListController : MyViewController <PhotoHeaderSegmentDelegate, SquareImageDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, FooterActionsDelegate> {
    
    ElasticSearchDao *elasticSearchDao;
    AlbumListDao *albumListDao;
    AddAlbumDao *addAlbumDao;
    DeleteDao *deleteDao;
    DeleteAlbumsDao *deleteAlbumDao;
    AlbumAddPhotosDao *albumAddPhotosDao;
    
    CustomButton *moreButton;
    
    float normalizedContentHeight;
    float maximizedContentHeight;
    
    UIBarButtonItem *previousButtonRef;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) PhotoHeaderSegmentView *headerView;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *albumList;
@property (nonatomic, strong) UITableView *albumTable;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) NSMutableArray *selectedAlbumList;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic, strong) FooterActionsMenuView *albumFooterActionMenu;

@end

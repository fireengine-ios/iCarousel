//
//  GroupedPhotosAndVideosController.h
//  Depo
//
//  Created by Mahir Tarlan on 26/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "SearchByGroupDao.h"
#import "FileInfoGroup.h"
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
#import "ImagePreviewController.h"
#import "VideoPreviewController.h"
#import "PhotoAlbumController.h"
#import "NoItemCell.h"
#import "NoItemView.h"

@interface GroupedPhotosAndVideosController : MyViewController <PhotoHeaderSegmentDelegate, SquareImageDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, FooterActionsDelegate, ImagePreviewDelegate, VideoPreviewDelegate, PhotoAlbumDelegate> {

    SearchByGroupDao *groupDao;
    AlbumListDao *albumListDao;
    AddAlbumDao *addAlbumDao;
    DeleteDao *deleteDao;
    DeleteAlbumsDao *deleteAlbumDao;
    AlbumAddPhotosDao *albumAddPhotosDao;
    
    CustomButton *moreButton;
    
    UIBarButtonItem *previousButtonRef;
    
    BOOL isLoading;
    BOOL isSelectible;
    
    NoItemCell *noItemCell;
    NoItemView *noItemView;
    
    MyNavigationController *printNav;
    
    int albumTableUpdateCounter;
    int photoTableUpdateCounter;

    int albumListOffset;
    int photoListOffset;
}

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) PhotoHeaderSegmentView *headerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *albumList;
@property (nonatomic, strong) UITableView *mainTable;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) NSMutableArray *selectedAlbumList;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic, strong) FooterActionsMenuView *albumFooterActionMenu;
@property (nonatomic) int photoCount;
@property (nonatomic) ImageGroupLevel level;
@property (nonatomic) PhotoHeaderSegmentType segmentType;
@property (nonatomic, strong) NSString *groupDate;

- (id) initWithLevel:(ImageGroupLevel) levelVal withGroupDate:(NSString *) groupDateVal;

@end

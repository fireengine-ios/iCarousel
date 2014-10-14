//
//  PhotoListController.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FileListDao.h"
#import "MetaFile.h"
#import "PhotoHeaderSegmentView.h"
#import "SquareImageView.h"
#import "AlbumListDao.h"

@interface PhotoListController : MyViewController <PhotoHeaderSegmentDelegate, SquareImageDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    FileListDao *fileListDao;
    AlbumListDao *albumListDao;
    
    float normalizedContentHeight;
    float maximizedContentHeight;
    
    int listOffset;
    BOOL isLoading;
}

@property (nonatomic, strong) PhotoHeaderSegmentView *headerView;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *albumList;
@property (nonatomic, strong) UITableView *albumTable;

@end

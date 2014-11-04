//
//  MusicListController.h
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "AbstractFileFolderCell.h"

@interface MusicListController : MyViewController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate> {
    ElasticSearchDao *elasticSearchDao;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) UITableView *musicTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *musicList;
@property (nonatomic, strong) NSMutableArray *selectedMusicList;

@end

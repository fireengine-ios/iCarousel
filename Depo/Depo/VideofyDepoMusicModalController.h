//
//  VideofyDepoMusicModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 10/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "AbstractFileFolderCell.h"

@interface VideofyDepoMusicModalController : MyViewController <UITableViewDataSource, UITableViewDelegate> {
    ElasticSearchDao *elasticSearchDao;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) UITableView *musicTable;
@property (nonatomic, strong) NSMutableArray *musicList;

@end

//
//  RecentActivitiesController.h
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "RecentActivitiesDao.h"
#import "Activity.h"

@interface RecentActivitiesController : MyModalController <UITableViewDataSource, UITableViewDelegate> {
    RecentActivitiesDao *recentDao;

    int tableUpdateCount;
    int listOffset;
    BOOL isLoading;
}

@property (nonatomic, strong) UITableView *recentTable;
@property (nonatomic, strong) NSDictionary *recentActivities;
@property (nonatomic, strong) NSArray *recentActivityKeys;
@property (nonatomic, strong) NSMutableArray *rawItems;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSDateFormatter *dateFormat;

@end

//
//  RecentActivitiesController.m
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentActivitiesController.h"
#import "RecentActivityCell.h"
#import "RecentActivityHeaderView.h"
#import "ActivityUtil.h"

@interface RecentActivitiesController ()

@end

@implementation RecentActivitiesController

@synthesize recentTable;
@synthesize recentActivities;
@synthesize recentActivityKeys;
@synthesize rawItems;
@synthesize refreshControl;
@synthesize dateFormat;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"RecentActivitiesTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        recentDao = [[RecentActivitiesDao alloc] init];
        recentDao.delegate = self;
        recentDao.successMethod = @selector(recentSuccessCallback:);
        recentDao.failMethod = @selector(recentFailCallback:);
        
        tableUpdateCount = 0;
        listOffset = 0;
        endOfList = NO;
        
        self.dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy"];

        recentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex , self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        recentTable.delegate = self;
        recentTable.dataSource = self;
        recentTable.backgroundColor = [UIColor clearColor];
        recentTable.backgroundView = nil;
        recentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:recentTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [recentTable addSubview:refreshControl];
        
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerDismissModal) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        self.navigationItem.leftBarButtonItem = backButton;

        [recentDao requestRecentActivitiesForPage:listOffset andCount:RECENT_ACTIVITY_COUNT];
    }
    return self;
}

- (void)  triggerDismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) triggerRefresh {
    [rawItems removeAllObjects];
    rawItems = nil;

    listOffset = 0;
    [recentDao requestRecentActivitiesForPage:listOffset andCount:RECENT_ACTIVITY_COUNT];
    tableUpdateCount++;
}

- (void) recentSuccessCallback:(NSArray *) recentItems {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;

    if(!recentItems)
        return;
    
    if(!rawItems) {
        rawItems = [ActivityUtil mergedActivityList:[[NSMutableArray alloc] init] withAdditionalList:recentItems];
    } else {
        rawItems = [ActivityUtil mergedActivityList:rawItems withAdditionalList:recentItems];
    }
    
    NSMutableArray *filteredRawFiles = [[NSMutableArray alloc] init];
    for(Activity *activity in rawItems) {
        [ActivityUtil enrichTitleForActivity:activity];
        if(activity.title != nil) {
            [filteredRawFiles addObject:activity];
        }
    }
    self.rawItems = filteredRawFiles;
    
    [self reorganiseActivities:rawItems];

    [self.recentTable reloadData];
    if([recentItems count] > 0) {
        Activity *lastItem = [recentItems objectAtIndex:recentItems.count - 1];
        if ([lastItem.rawActivityType isEqualToString:@"WELCOME"]) {
            endOfList = YES;
        }
    }
}

- (void) recentFailCallback:(NSString *) errorMessage {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;
}

- (void) reorganiseActivities:(NSArray *) activities {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for(Activity *activity in activities) {
        NSString *dateForActivity = [dateFormat stringFromDate:activity.date];
        if([result objectForKey:dateForActivity]) {
            NSMutableArray *dateArray = [result objectForKey:dateForActivity];
            [dateArray addObject:activity];
            [result setObject:dateArray forKey:dateForActivity];
        } else {
            NSMutableArray *dateArray = [[NSMutableArray alloc] init];
            [dateArray addObject:activity];
            [result setObject:dateArray forKey:dateForActivity];
        }
    }

    self.recentActivityKeys = [result keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        NSArray *arr1 = (NSArray *) obj1;
        NSArray *arr2 = (NSArray *) obj2;
        Activity *a1 = [arr1 objectAtIndex:0];
        Activity *a2 = [arr2 objectAtIndex:0];
        return (NSComparisonResult)[a2.date compare:a1.date];
    }];
    self.recentActivities = result;
}

#pragma mark Table methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [recentActivityKeys objectAtIndex:indexPath.section];
    NSMutableArray *objs = [recentActivities objectForKey:key];
    Activity *activity = [objs objectAtIndex:indexPath.row];
    if([activity.rawFileType isEqualToString:@"IMAGE"]) {
        if([activity.actionItemList count] > 0) {
            return 100;
        } else {
            return 70;
        }
    } else {
        return 70 + [activity.actionItemList count] * 18;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [recentActivityKeys objectAtIndex:section];
    return [[recentActivities objectForKey:key] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [recentActivityKeys count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [recentActivityKeys objectAtIndex:section];
    if(sectionKey) {
        NSDate *sectionDate = [dateFormat dateFromString:sectionKey];
        return [[RecentActivityHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30) withDate:sectionDate withIndex:section];
    } else {
        return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"RECENT_ACTIVITY_%d_%d_%d", tableUpdateCount, (int)indexPath.row, (int)indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        NSString *key = [recentActivityKeys objectAtIndex:indexPath.section];
        NSMutableArray *objs = [recentActivities objectForKey:key];
        Activity *activity = [objs objectAtIndex:indexPath.row];
        cell = [[RecentActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withActivity:activity];
    }
    return cell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = recentTable.contentOffset.y;
        CGFloat maximumOffset = recentTable.contentSize.height - recentTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    if (!endOfList) {
        listOffset ++;
        [recentDao requestRecentActivitiesForPage:listOffset andCount:RECENT_ACTIVITY_COUNT];
        tableUpdateCount++;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"RecentActivitiesController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) cancelRequests {
    [recentDao cancelRequest];
    recentDao = nil;
}

@end

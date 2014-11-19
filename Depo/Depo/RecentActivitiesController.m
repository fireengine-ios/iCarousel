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

@interface RecentActivitiesController ()

@end

@implementation RecentActivitiesController

@synthesize recentTable;
@synthesize recentActivities;
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
        
        self.dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy"];

        recentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 20, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 20) style:UITableViewStylePlain];
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

        [recentDao requestRecentActivitiesForOffset:listOffset andCount:RECENT_ACTIVITY_COUNT];
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
    [recentDao requestRecentActivitiesForOffset:listOffset andCount:RECENT_ACTIVITY_COUNT];
    tableUpdateCount++;
}

- (void) recentSuccessCallback:(NSArray *) recentItems {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }

    if(!rawItems) {
        rawItems = [[NSMutableArray alloc] init];
    }
    [rawItems addObjectsFromArray:recentItems];
    [self reorganiseActivities:rawItems];

    [self.recentTable reloadData];
}

- (void) recentFailCallback:(NSString *) errorMessage {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
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
    self.recentActivities = result;
}

#pragma mark Table methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [[recentActivities allKeys] objectAtIndex:section];
    return [[recentActivities objectForKey:key] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [[recentActivities allKeys] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [[recentActivities allKeys] objectAtIndex:section];
    if(sectionKey) {
        NSDate *sectionDate = [dateFormat dateFromString:sectionKey];
        return [[RecentActivityHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30) withDate:sectionDate];
    } else {
        return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"RECENT_ACTIVITY_%d_%d_%d", tableUpdateCount, (int)indexPath.row, (int)indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        NSString *key = [[recentActivities allKeys] objectAtIndex:indexPath.section];
        NSMutableArray *objs = [recentActivities objectForKey:key];
        Activity *activity = [objs objectAtIndex:indexPath.row];
        cell = [[RecentActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withActivity:activity];
    }
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end

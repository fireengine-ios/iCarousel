//
//  RecentSearchesController.m
//  Depo
//
//  Created by NCO on 24/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentSearchesTableView.h"
#import "RecentSearchCell.h"
#import "Util.h"
#import "CacheUtil.h"
#import "SearchHistory.h"
#import "TableHeaderView.h"

@interface RecentSearchesTableView ()

@end

@implementation RecentSearchesTableView

@synthesize dataArray, searchMethod, ownerController, tableHeight;

- (id)initWithSearchField:(SearchTextField *)srchFld {
    self = [super init];
    if (self) {
        searchField = srchFld;
        visibleStatus = NO;
        self.delegate = self;
        self.dataSource = self;
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.backgroundColor = [UIColor clearColor];
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"SearchHistoryCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    SearchHistory *searchHistoryItem = [self.dataArray objectAtIndex:indexPath.row];
    RecentSearchCell *cell = [[RecentSearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier title:searchHistoryItem.searchText];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableHeaderView *tableHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35) andTitleText:NSLocalizedString(@"RECENT SEARCHES", @"")];
    tableHeaderView.userInteractionEnabled = YES;
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(crossButtonOutAction)];
    [tableHeaderView addGestureRecognizer:touchOnView];
    
    crossButton = [[CustomButton alloc]initWithFrame:CGRectMake(275, 3, 29, 29) withImageName:@"close_icon"];
    [crossButton addTarget:self action:@selector(crossButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:crossButton];
    
    
    float clearButtonWidth = [NSLocalizedString(@"Clear", @"") length] < 6 ? 43 : 55;
    clearButton = [[UIButton alloc]initWithFrame:CGRectMake(299-clearButtonWidth, 8, clearButtonWidth, 19)];
    [clearButton setTitle:NSLocalizedString(@"Clear", @"") forState:UIControlStateNormal];
    clearButton.backgroundColor = [Util UIColorForHexColor:@"BABBBD"];
    clearButton.layer.cornerRadius = 10.5f;
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:15];
    [clearButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    return tableHeaderView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchHistory *searchHistory = [[SearchHistory alloc]init];
    searchHistory = [dataArray objectAtIndex:indexPath.row];
    [searchField setText:searchHistory.searchText];
    [searchField resignFirstResponder];
    [self hideTableView];
    SuppressPerformSelectorLeakWarning([ownerController performSelector:searchMethod withObject:searchHistory.searchText]);
}

- (void)crossButtonAction {
    [UIView transitionFromView:crossButton toView:clearButton duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:nil];
}

- (void)crossButtonOutAction {
    [UIView transitionFromView:clearButton toView:crossButton duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:nil];
}

- (void)clearButtonAction {
    [self hideTableView];
    [CacheUtil clearSearchHistoryItems];
}

- (void)showTableView {
    NSArray *searchHistoryItemsArray = [CacheUtil readSearchHistoryItems];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[[searchHistoryItemsArray reverseObjectEnumerator] allObjects]];
    [self reloadData];
    [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    if (!visibleStatus && self.dataArray.count > 0) {
        visibleStatus = YES;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.tableHeight, self.frame.size.width, self.frame.size.height);
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (void)hideTableView {
    if (visibleStatus) {
        visibleStatus = NO;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.tableHeight, self.frame.size.width, self.frame.size.height);
                         } completion:^(BOOL finished) {
                         }];
    }
    
}

- (void)addTextToSearchHistory:(NSString *)text {
    SearchHistory *searchHistory = [[SearchHistory alloc]init];
    searchHistory.searchText = text;
    searchHistory.searchDate = [NSDate date];
    [CacheUtil cacheSearchHistoryItem:searchHistory];
}

@end

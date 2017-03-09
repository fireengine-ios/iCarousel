//
//  CountrySelectionController.m
//  Depo
//
//  Created by RDC on 09/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "CountrySelectionController.h"

@interface CountrySelectionController ()

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation CountrySelectionController

static const CGFloat topOffset = 64; // use 20 if there's no navigation bar, or zero if there's no status bar either

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Country Selection";
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, topOffset, self.view.frame.size.width, 40)];
    [_searchBar setBarTintColor:[UIColor colorWithRed:245.0f/255.0f green:245/255.0f blue:245/255.0f alpha:1.0f]];
    _searchBar.placeholder = @"Ara";
    self.tableView.tableHeaderView = self.searchBar;
    
//    self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
//    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.searchBar.frame;
    frame.origin.y = scrollView.contentOffset.y + topOffset;
    self.searchBar.frame = frame;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = @"Hello World";
    return cell;
}

@end

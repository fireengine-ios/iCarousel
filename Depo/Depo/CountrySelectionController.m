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
@property (nonatomic) NSDictionary *countryDict;
@property (nonatomic) NSMutableDictionary *filteredCountryDict;
@property (nonatomic) NSArray *keys;

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
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countryCodes" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSArray *countryArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:kNilOptions
                                                            error:nil];

        _countryDict = [self sortCountryArray:countryArray];
        _filteredCountryDict = [NSMutableDictionary dictionaryWithDictionary:_countryDict];
        _keys = [self getSortedKeysFromDict:_filteredCountryDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"X"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(back:)];
            barButton.tintColor = [UIColor whiteColor];
            [self.navigationItem setRightBarButtonItem:barButton];
            [self.tableView reloadData];
        });
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)getSortedKeysFromDict:(NSDictionary*)dict {
    return [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary*)sortCountryArray:(NSArray*)dictionaryArray {
    NSMutableArray * sourceArray = [dictionaryArray mutableCopy];
    [sourceArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 objectForKey:@"country_name"] compare:[obj2 objectForKey:@"country_name"]];
    }];
    
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
    for (unichar firstChar = 'A'; firstChar <= 'Z'; firstChar ++) {
        [resultDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%C",firstChar]];
    }
    for (NSDictionary * dic in sourceArray) {
        [resultDic[[dic[@"country_name"] substringToIndex:1]] addObject:dic];
    }
    for (NSString * key in [resultDic allKeys]) {
        if ([resultDic[key] count] == 0) {
            [resultDic removeObjectForKey:key];
        }
    }
    return resultDic;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_filteredCountryDict) {
        return [_filteredCountryDict count];
    }
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_filteredCountryDict) {
        return [[_filteredCountryDict valueForKey: [_keys objectAtIndex:section]] count];
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_keys objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    if (_filteredCountryDict) {
        NSDictionary * countryDic = [_filteredCountryDict valueForKey:[_keys objectAtIndex:[indexPath section]]][indexPath.row];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setText:countryDic[@"country_name"]];
        return cell;
    }
    return cell;;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _keys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_completion) {
        _completion([_filteredCountryDict valueForKey:[_keys objectAtIndex:[indexPath section]]][indexPath.row]);
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UISearch Bar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //TODO: CountryDict harfli sectionlara ayrildigi icin bu index kullanilark asagidaki algoritma daha da gelistirilebilir
    _filteredCountryDict = [NSMutableDictionary new];
    for (NSString *key in [_countryDict allKeys]) {
        NSArray *items = _countryDict[key];
        
        NSMutableArray *section = [NSMutableArray new];
        for (NSDictionary *item in items) {
            NSComparisonResult result = [item[@"country_name"] compare:searchText
                                                               options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                                 range:NSMakeRange(0, [searchText length])];
            
            if (result == NSOrderedSame) {
                NSLog(@"item= %@", item[@"country_name"]);
                [section addObject:item];
            }
        }
        if (section.count > 0) {
            _filteredCountryDict[key] = section;
        }
    }
    
    _keys = [self getSortedKeysFromDict:_filteredCountryDict];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchBar.text = @"";
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
}


@end

//
//  SearchModalController.h
//  Depo
//
//  Created by NCO on 18/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SearchTextField.h"
#import "RecentSearchesTableView.h"
#import "SearchDao.h"

@interface SearchModalController : MyModalController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    UIView *searchFieldContainer;
    SearchTextField *searchField;
    RecentSearchesTableView *recentSearchesTableView;
    UITableView *searchResultsTable;
    SearchDao *searchDao;
    int listOffset;
    int tableUpdateCounter;
    NSMutableArray *fileList;
    NSMutableArray *docList;
    NSMutableArray *photoVideoList;
    NSMutableArray *musicList;
    NSString *currentSearchText;
    BOOL animateSearchArea;
    float tableHeight;
}

- (void)startSearch:(NSString *)searchText;

@end

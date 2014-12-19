//
//  SearchMoreModalController.h
//  Depo
//
//  Created by RDC on 03.12.14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SearchDao.h"

@interface SearchMoreModalController : MyModalController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *searchResultsTable;
    SearchDao *searchDao;
    int listOffset;
    int tableUpdateCounter;
    NSMutableArray *fileList;
    int searchListType;
    NSString *searchText;
    int fileCount;
    BOOL isLoading;
    SearchDao *loadMoreDao;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (id) initWithSearchText:(NSString *)srchTxt andSearchListType:(int)srchLstTyp andFileCount:(int)flCnt;

@end

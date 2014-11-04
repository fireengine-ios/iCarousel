//
//  DocListController.m
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DocListController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "FolderEmptyCell.h"
#import "SimpleDocCell.h"
#import "FileDetailInWebViewController.h"
#import "PreviewUnavailableController.h"

@interface DocListController ()

@end

@implementation DocListController

@synthesize docTable;
@synthesize refreshControl;
@synthesize docList;
@synthesize selectedDocList;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"DocTitle", @"");
        
        listOffset = 0;
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(docListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(docListFailCallback:);
        
        docTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        docTable.delegate = self;
        docTable.dataSource = self;
        docTable.backgroundColor = [UIColor clearColor];
        docTable.backgroundView = nil;
        docTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:docTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [docTable addSubview:refreshControl];
        
        [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
    }
    return self;
}

- (void) triggerRefresh {
    listOffset = 0;
    [docList removeAllObjects];
    [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) docListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;
    
    if(docList == nil) {
        docList = [[NSMutableArray alloc] init];
    }
    [docList addObjectsFromArray:[self filterFilesFromList:files]];
    
    self.tableUpdateCounter ++;
    [docTable reloadData];
}

- (void) docListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(docList == nil) {
        return 0;
    } else if([docList count] == 0) {
        return 1;
    } else {
        return [docList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(docList == nil || [docList count] == 0) {
        return 320;
    } else {
        return 68;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"DOC_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(docList == nil || [docList count] == 0) {
            cell = [[FolderEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFolderTitle:@""];
        } else {
            MetaFile *fileAtIndex = [docList objectAtIndex:indexPath.row];
            cell = [[SimpleDocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
            ((AbstractFileFolderCell *) cell).delegate = self;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible)
        return;
    
    MetaFile *fileAtIndex = [docList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    FileDetailInWebViewController *preview = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
    preview.nav = self.nav;
    [self.nav pushViewController:preview animated:NO];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = docTable.contentOffset.y;
        CGFloat maximumOffset = docTable.contentSize.height - docTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

#pragma mark AbstractFileFolderDelegate methods

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldDeleteForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
}

- (NSMutableArray *) filterFilesFromList:(NSArray *) list {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(MetaFile *row in list) {
        if(!row.folder) {
            [result addObject:row];
        }
    }
    return result;
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

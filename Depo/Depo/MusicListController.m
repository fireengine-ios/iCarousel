//
//  MusicListController.m
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicListController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "FolderEmptyCell.h"
#import "SimpleMusicCell.h"
#import "MusicPreviewController.h"
#import "BaseViewController.h"

@interface MusicListController ()

@end

@implementation MusicListController

@synthesize musicTable;
@synthesize refreshControl;
@synthesize musicList;
@synthesize selectedMusicList;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"MusicTitle", @"");

        listOffset = 0;

        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(musicListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(musicListFailCallback:);

        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback:);
        favoriteDao.failMethod = @selector(favFailCallback:);

        moveDao = [[MoveDao alloc] init];
        moveDao.delegate = self;
        moveDao.successMethod = @selector(moveSuccessCallback);
        moveDao.failMethod = @selector(moveFailCallback:);

        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        selectedMusicList = [[NSMutableArray alloc] init];
        
        musicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        musicTable.delegate = self;
        musicTable.dataSource = self;
        musicTable.backgroundColor = [UIColor clearColor];
        musicTable.backgroundView = nil;
        musicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:musicTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [musicTable addSubview:refreshControl];
        
        [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
    }
    return self;
}

- (void) triggerRefresh {
    listOffset = 0;
    [musicList removeAllObjects];
    [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) musicListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;

    if(musicList == nil) {
        musicList = [[NSMutableArray alloc] init];
    }
    [musicList addObjectsFromArray:files];

    self.tableUpdateCounter ++;
    [musicTable reloadData];
}

- (void) musicListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(musicList == nil) {
        return 0;
    } else if([musicList count] == 0) {
        return 1;
    } else {
        return [musicList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(musicList == nil || [musicList count] == 0) {
        return 320;
    } else {
        return 68;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MUSIC_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(musicList == nil || [musicList count] == 0) {
            cell = [[FolderEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFolderTitle:@""];
        } else {
            MetaFile *fileAtIndex = [musicList objectAtIndex:indexPath.row];
            cell = [[SimpleMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
            ((AbstractFileFolderCell *) cell).delegate = self;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible)
        return;
    
    MetaFile *fileAtIndex = [musicList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    MusicPreviewController *preview = [[MusicPreviewController alloc] initWithFile:fileAtIndex];
    preview.nav = self.nav;
    [self.nav pushViewController:preview animated:NO];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = musicTable.contentOffset.y;
        CGFloat maximumOffset = musicTable.contentSize.height - musicTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

#pragma mark AbstractFileFolderDelegate methods

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) fileFolderCellShouldDeleteForFile:(MetaFile *)fileSelected {
    [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    selectedMusicList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [APPDELEGATE.base showMoveFolders];
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    [moveDao requestMoveFiles:selectedMusicList toFolder:folderUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"MoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"MoveFailMessage", @"")];
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort]]];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) moveSuccessCallback {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) moveFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
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

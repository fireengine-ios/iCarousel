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
@synthesize selectedMusicList;
@synthesize musicDict;
@synthesize musicDictKeys;
@synthesize footerActionMenu;

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
        musicDict = [[NSMutableDictionary alloc] init];
        musicDictKeys = [[NSMutableArray alloc] init];
        
        musicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        musicTable.delegate = self;
        musicTable.dataSource = self;
        musicTable.backgroundColor = [UIColor clearColor];
        musicTable.backgroundView = nil;
        musicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        musicTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
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
    [musicDict removeAllObjects];
    [musicDictKeys removeAllObjects];
    [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) musicListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;

    for(MetaFile *file in files) {
        NSString *sortVal = file.name;
        if(file.detail) {
            if(APPDELEGATE.session.sortType == SortTypeAlbumAsc || APPDELEGATE.session.sortType == SortTypeAlbumDesc) {
                sortVal = file.detail.album;
            } else if(APPDELEGATE.session.sortType == SortTypeArtistAsc || APPDELEGATE.session.sortType == SortTypeArtistDesc) {
                sortVal = file.detail.artist;
            }
        }
        NSString *sortValKey = [sortVal length] > 0 ? [sortVal substringToIndex:1] : @" ";
        if(![musicDictKeys containsObject:sortValKey]) {
            [musicDictKeys addObject:sortValKey];
            NSMutableArray *filesForKey = [[NSMutableArray alloc] initWithObjects:file, nil];
            [musicDict setObject:filesForKey forKey:sortValKey];
        } else {
            NSMutableArray *filesForKey = [musicDict objectForKey:sortValKey];
            [filesForKey addObject:file];
            [musicDict setObject:filesForKey forKey:sortValKey];
        }
    }

    self.tableUpdateCounter ++;
    [musicTable reloadData];
}

- (void) musicListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [musicDictKeys objectAtIndex:section];
    NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
    return [sectionArray count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [musicDictKeys count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return musicDictKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [musicDictKeys indexOfObject:title];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //setting color for section indexes
    for(UIView *view in [tableView subviews]) {
        if([[[view class] description] isEqualToString:@"UITableViewIndex"]) {
            [view performSelector:@selector(setIndexColor:) withObject:[Util UIColorForHexColor:@"555555"]];
        }
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"MUSIC_CELL_%d_%d_%d", (int)indexPath.row, (int)indexPath.section, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        NSString *sectionKey = [musicDictKeys objectAtIndex:indexPath.section];
        NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
        MetaFile *fileAtIndex = [sectionArray objectAtIndex:indexPath.row];
        cell = [[SimpleMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
        ((AbstractFileFolderCell *) cell).delegate = self;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible)
        return;
    
    NSString *sectionKey = [musicDictKeys objectAtIndex:indexPath.section];
    NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
    MetaFile *fileAtIndex = [sectionArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    MusicPreviewController *preview = [[MusicPreviewController alloc] initWithFile:fileAtIndex.uuid withFileList:[self rawMusicList]];
    preview.nav = self.nav;
    [self.nav pushViewController:preview animated:NO];
    
}

- (NSMutableArray *) rawMusicList {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(NSString *key in musicDictKeys) {
        NSArray *musics = [musicDict objectForKey:key];
        if(musics != nil) {
            [result addObjectsFromArray:musics];
        }
    }
    return result;
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
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        fileSelectedRef = fileSelected;
        self.deleteType = DeleteTypeSwipeMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    selectedMusicList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [APPDELEGATE.base showMoveFolders];
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
    if(![selectedMusicList containsObject:fileSelected.uuid]) {
        [selectedMusicList addObject:fileSelected.uuid];
    }
    if([selectedMusicList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedMusicList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
    if([selectedMusicList containsObject:fileSelected.uuid]) {
        [selectedMusicList removeObject:fileSelected.uuid];
    }
    if([selectedMusicList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedMusicList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) showFooterMenu {
    footerActionMenu.hidden = NO;
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    [moveDao requestMoveFiles:selectedMusicList toFolder:folderUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"MoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"MoveFailMessage", @"")];
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        for (NSInteger j = 0; j < [musicTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [musicTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [musicTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedMusicList containsObject:fileCell.fileFolder.uuid]) {
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedMusicList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

#pragma mark MoreMenuDelegate
- (void) moreMenuDidSelectSortWithList {
    [APPDELEGATE.base showSortWithList:[NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeSongNameAsc], [NSNumber numberWithInt:SortTypeSongNameDesc], [NSNumber numberWithInt:SortTypeArtistAsc], [NSNumber numberWithInt:SortTypeArtistDesc], [NSNumber numberWithInt:SortTypeAlbumAsc], [NSNumber numberWithInt:SortTypeAlbumDesc], nil]];
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSortWithList], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
    NSLog(@"At INNER confirmDeleteDidCancel");
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeFooterMenu) {
        for (NSInteger j = 0; j < [musicTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [musicTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [musicTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedMusicList containsObject:fileCell.fileFolder.uuid]) {
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedMusicList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else if(self.deleteType == DeleteTypeSwipeMenu) {
        [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    }
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    previousButtonRef = self.navigationItem.leftBarButtonItem;
    
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelSelectible) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedMusicList removeAllObjects];
    
    self.tableUpdateCounter++;
    [self.musicTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
    footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES];
    footerActionMenu.delegate = self;
    footerActionMenu.hidden = YES;
    [self.view addSubview:footerActionMenu];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"MusicTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedMusicList removeAllObjects];
    
    [APPDELEGATE.base immediateShowAddButton];
    
    self.tableUpdateCounter++;
    [self.musicTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
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
    if(isSelectible) {
        self.title = NSLocalizedString(@"MusicTitle", @"");
        self.navigationItem.leftBarButtonItem = previousButtonRef;
        moreButton.hidden = NO;
        
        isSelectible = NO;
        [selectedMusicList removeAllObjects];
        
        if(footerActionMenu) {
            [footerActionMenu removeFromSuperview];
        }
    }
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

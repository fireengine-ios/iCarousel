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
#import "NoItemCell.h"
#import "SimpleMusicCell.h"
#import "BaseViewController.h"
#import "ShareActivity.h"

@interface MusicListController ()

@end

@implementation MusicListController

@synthesize musicTable;
@synthesize refreshControl;
@synthesize selectedMusicList;
@synthesize musicDict;
@synthesize musicDictKeys;
@synthesize uuidsToBeDeleted;
@synthesize footerActionMenu;
@synthesize searchField;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"MusicTitle", @"");

        listOffset = 0;
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(musicListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(musicListFailCallback:);
        
        loadMoreDao = [[ElasticSearchDao alloc] init];
        loadMoreDao.delegate = self;
        loadMoreDao.successMethod = @selector(loadMoreSuccessCallback:);
        loadMoreDao.failMethod = @selector(loadMoreFailCallback:);

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
        //musicDictKeys = [[NSMutableArray alloc] init];
        self.musicDictKeys = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"R", @"S", @"T", @"U", @"V", @"Y", @"Z", @"#"];
        
        self.topIndex = 10;
        
        UIView *searchContainer = [[UIView alloc] initWithFrame:CGRectMake(20, self.topIndex, self.view.frame.size.width, 60)];
        searchField = [[MainSearchTextfield alloc] initWithFrame:CGRectMake(0, 0, searchContainer.frame.size.width - 40, 40)];
        searchField.delegate = self;
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.userInteractionEnabled = NO;
        searchField.isAccessibilityElement = YES;
        searchField.accessibilityIdentifier = @"searchFieldAllFiles";
        [searchContainer addSubview:searchField];
        [self.view addSubview:searchContainer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [searchContainer addGestureRecognizer:tapGestureRecognizer];
        
        self.topIndex+=50;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"BEBEBE"];
        [self.view addSubview:separator];
        
        self.topIndex+=1;
        
        musicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        musicTable.delegate = self;
        musicTable.dataSource = self;
        musicTable.backgroundColor = [UIColor clearColor];
        musicTable.backgroundView = nil;
        musicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        musicTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        musicTable.isAccessibilityElement = YES;
        musicTable.accessibilityIdentifier = @"musicTableMusicList";
        [self.view addSubview:musicTable];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shouldMoveToSelectionState:)];
//        longPressGesture.minimumPressDuration = 1.0;
        [musicTable addGestureRecognizer:longPressGesture];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [musicTable addSubview:refreshControl];
        
        [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
    }
    return self;
}

- (void) shouldMoveToSelectionState:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:musicTable];
            NSIndexPath *indexPath = [musicTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                [self changeToSelectedStatus];
            }
        }
    }
}

- (void) triggerRefresh {
    if(isSelectible) {
        [refreshControl endRefreshing];
        return;
    }

    listOffset = 0;
    if(musicDict) {
        [musicDict removeAllObjects];
    }
    [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) musicListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;

    if(!musicDict) {
        musicDict = [[NSMutableDictionary alloc] init];
    }

    for(MetaFile *file in files) {
        NSString *sortVal = file.name;
        if(file.detail) {
            if(APPDELEGATE.session.sortType == SortTypeAlbumAsc || APPDELEGATE.session.sortType == SortTypeAlbumDesc) {
                sortVal = file.detail.album;
            } else if(APPDELEGATE.session.sortType == SortTypeArtistAsc || APPDELEGATE.session.sortType == SortTypeArtistDesc) {
                sortVal = file.detail.artist;
            }
        }
        NSString *sortValKey = [[sortVal length] > 0 ? [sortVal substringToIndex:1] : @" " uppercaseString];
        if(![musicDictKeys containsObject:sortValKey]) {
            sortValKey = @"#";
        }
        if([musicDict objectForKey:sortValKey] == nil) {
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

- (void) loadMoreSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    
    for(MetaFile *file in files) {
        NSString *sortVal = file.name;
        if(file.detail) {
            if(APPDELEGATE.session.sortType == SortTypeAlbumAsc || APPDELEGATE.session.sortType == SortTypeAlbumDesc) {
                sortVal = file.detail.album;
            } else if(APPDELEGATE.session.sortType == SortTypeArtistAsc || APPDELEGATE.session.sortType == SortTypeArtistDesc) {
                sortVal = file.detail.artist;
            }
        }
        NSString *sortValKey = [[sortVal length] > 0 ? [sortVal substringToIndex:1] : @" " uppercaseString];
        if(![musicDictKeys containsObject:sortValKey]) {
            sortValKey = @"#";
        }
        if([musicDict objectForKey:sortValKey] == nil) {
            NSMutableArray *filesForKey = [[NSMutableArray alloc] initWithObjects:file, nil];
            [musicDict setObject:filesForKey forKey:sortValKey];
        } else {
            NSMutableArray *filesForKey = [musicDict objectForKey:sortValKey];
            [filesForKey addObject:file];
            [musicDict setObject:filesForKey forKey:sortValKey];
        }
    }
    
    isLoading = NO;
    //    self.tableUpdateCounter ++;
    [musicTable reloadData];
}

- (void) loadMoreFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    //TODO check    [self showErrorAlertWithMessage:errorMessage];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(musicDict == nil)
        return 0;
    
    if([[musicDict allKeys] count] == 0 && section == 0)
        return 1;
    
    NSString *sectionKey = [musicDictKeys objectAtIndex:section];
    NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
    if(sectionArray == nil) {
        return 0;
    } else {
        return [sectionArray count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [musicDictKeys count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[musicDict allKeys] count] == 0) {
        if(IS_IPAD) {
            return 420;
        } else {
            return 320;
        }
    } else {
        if(IS_IPAD) {
            return 102;
        } else {
            return 68;
        }
    }
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
        if([[musicDict allKeys] count] == 0) {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_music_icon" titleText:NSLocalizedString(@"EmptyMusicTitle", @"") descriptionText:@""];
        } else {
            NSString *sectionKey = [musicDictKeys objectAtIndex:indexPath.section];
            NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
            MetaFile *fileAtIndex = [sectionArray objectAtIndex:indexPath.row];
            cell = [[SimpleMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
            ((AbstractFileFolderCell *) cell).delegate = self;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(isSelectible) {
        if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
            AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
            [fileFolderCell triggerFileSelectDeselect];
        }
        return;
    }

    if([cell isKindOfClass:[NoItemCell class]]) {
        return;
    }
    
    NSString *sectionKey = [musicDictKeys objectAtIndex:indexPath.section];
    NSMutableArray *sectionArray = [musicDict objectForKey:sectionKey];
    MetaFile *fileAtIndex = [sectionArray objectAtIndex:indexPath.row];
    
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    MusicPreviewController *preview = [[MusicPreviewController alloc] initWithFile:fileAtIndex.uuid withFileList:[self rawMusicList]];
    preview.delegate = self;
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
    
- (void) searchTapped {
    [APPDELEGATE.base triggerInnerSearch];
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
//    [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
    [loadMoreDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];

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
        uuidsToBeDeleted = @[fileSelected.uuid];
        [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        fileSelectedRef = fileSelected;
        self.deleteType = DeleteTypeSwipeMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
    [self triggerShareForFiles:@[fileSelected.uuid]];
   // [APPDELEGATE.base triggerShareForFiles:@[fileSelected.uuid]];
}

#pragma mark - Share

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

#pragma mark ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self hideLoading];
    NSArray *activityItems = [NSArray arrayWithObjects:
                              [NSURL URLWithString:linkToShare], nil];
    
    ShareActivity *activity = [[ShareActivity alloc] init];
    activity.sourceViewController = self;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:@[activity]];
    
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
    
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    selectedMusicList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [MoreMenuView presentMoveFoldersListFromController:self.nav delegateOwner:self];
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
        uuidsToBeDeleted = selectedMusicList;
        [deleteDao requestDeleteFiles:selectedMusicList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}


#pragma mark MoreMenuDelegate
- (void) moreMenuDidSelectSortWithList {
    NSArray *list = [NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeSongNameAsc], [NSNumber numberWithInt:SortTypeSongNameDesc], [NSNumber numberWithInt:SortTypeArtistAsc], [NSNumber numberWithInt:SortTypeArtistDesc], [NSNumber numberWithInt:SortTypeAlbumAsc], [NSNumber numberWithInt:SortTypeAlbumDesc], nil];
    [MoreMenuView presnetSortWithList:list fromController:self.nav delegateOwner:self];
}

-(void)moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSortWithList], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
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
        uuidsToBeDeleted = selectedMusicList;
        [deleteDao requestDeleteFiles:selectedMusicList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else if(self.deleteType == DeleteTypeSwipeMenu) {
        uuidsToBeDeleted = @[fileSelectedRef.uuid];
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
    [cancelButton addTarget:self action:@selector(setToUnselectible) forControlEvents:UIControlEventTouchUpInside];
    
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
    footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES shouldShowPrint:NO];
    footerActionMenu.delegate = self;
    footerActionMenu.hidden = YES;
    [self.view addSubview:footerActionMenu];
}

- (void) setToUnselectible {
    self.title = NSLocalizedString(@"MusicTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedMusicList removeAllObjects];
    
//    [APPDELEGATE.base immediateShowAddButton];
    
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
    if(uuidsToBeDeleted) {
        [APPDELEGATE.session musicFileWasDeletedWithUuids:uuidsToBeDeleted];
    }
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

#pragma mark MusicPreviewDelegate methods

- (void) previewedMusicWasDeleted {
    [self triggerRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"MusicListController viewDidLoad");
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        musicTable.sectionIndexColor = [Util UIColorForHexColor:@"3FB0E8"];
    }
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
    [elasticSearchDao cancelRequest];
    elasticSearchDao = nil;
    
    [favoriteDao cancelRequest];
    favoriteDao = nil;

    [moveDao cancelRequest];
    moveDao = nil;

    [deleteDao cancelRequest];
    deleteDao = nil;
}

@end

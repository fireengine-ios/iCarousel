//
//  SearchMoreModalController.m
//  Depo
//
//  Created by RDC on 03.12.14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//


#import "SearchMoreModalController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "FolderCell.h"
#import "AbstractFileFolderCell.h"
#import "FolderEmptyCell.h"
#import "MusicCell.h"
#import "ImageCell.h"
#import "DocCell.h"
#import "TableHeaderView.h"
#import "MessageCell.h"
#import "FileListController.h"
#import "ImagePreviewController.h"
#import "MusicPreviewController.h"
#import "VideoPreviewController.h"
#import "FileDetailInWebViewController.h"
#import "PreviewUnavailableController.h"
#import "BaseViewController.h"

@interface SearchMoreModalController ()

@end

@implementation SearchMoreModalController

@synthesize refreshControl;

- (id) initWithSearchText:(NSString *)srchTxt andSearchListType:(int)srchLstTyp andFileCount:(int)flCnt {
    searchText = srchTxt;
    searchListType = srchLstTyp;
    fileCount = flCnt;
    
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"SearchTitle", @"");
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        searchResultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex)];
        searchResultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchResultsTable.hidden = YES;
        searchResultsTable.delegate = self;
        searchResultsTable.dataSource = self;
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventValueChanged];
        [searchResultsTable addSubview:refreshControl];
        
        searchDao = [[SearchDao alloc]init];
        searchDao.delegate = self;
        searchDao.successMethod = @selector(searchListSuccessCallback:);
        searchDao.failMethod = @selector(searchListFailCallback:);
        
        loadMoreDao = [[SearchDao alloc]init];
        loadMoreDao.delegate = self;
        loadMoreDao.successMethod = @selector(loadMoreSuccessCallback:);
        loadMoreDao.failMethod = @selector(searchListFailCallback:);
        
        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback:);
        favoriteDao.failMethod = @selector(favFailCallback:);

        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        moveDao = [[MoveDao alloc] init];
        moveDao.delegate = self;
        moveDao.successMethod = @selector(moveSuccessCallback);
        moveDao.failMethod = @selector(moveFailCallback:);

        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        [self.view addSubview:searchResultsTable];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[Util UIColorForHexColor:@"1a1e24"]];
    [self.navigationController.navigationBar setTintColor:[Util UIColorForHexColor:@"1a1e24"]];
    [self startSearch];
}

- (void)startSearch {
    if (!refreshControl) {
        [super showLoading];
        [super fadeOut:searchResultsTable duration:0.01];
    }
    listOffset = 0;
    [fileList removeAllObjects];
    
    
    tableUpdateCounter++;
    [searchDao requestMetadata:searchText andPage:0 andSize:NO_OF_FILES_PER_PAGE andSortType:APPDELEGATE.session.sortType andSearchListType:searchListType];
}

- (void) searchListSuccessCallback:(NSArray *) files {
    if (fileList == nil)
        fileList = [[NSMutableArray alloc] init];
    else
        [fileList removeAllObjects];

    [fileList addObjectsFromArray:files];
    
    isLoading = NO;
    tableUpdateCounter++;
    [searchResultsTable reloadData];
    
    if (refreshControl) {
        [refreshControl endRefreshing];
        [super fadeIn:searchResultsTable duration:0.1];
    }
    [super hideLoading];
}

- (void) searchListFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    if (refreshControl)
        [refreshControl endRefreshing];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void) loadMoreSuccessCallback:(NSArray *) files {
    [fileList addObjectsFromArray:files];
    isLoading = NO;
//    tableUpdateCounter++;
    [searchResultsTable reloadData];
    
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isLoading) {
        CGFloat currentOffset = searchResultsTable.contentOffset.y;
        CGFloat maximumOffset = searchResultsTable.contentSize.height - searchResultsTable.frame.size.height;
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset++;
    [loadMoreDao requestMetadata:searchText andPage:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE andSortType:APPDELEGATE.session.sortType andSearchListType:searchListType];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (fileList == nil || [fileList count] == 0)
        return 1;
    else
        return fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (fileList.count == 0)
        return 0;
    else
        return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(fileList == nil || [fileList count] == 0)
        return 320;
    else
        return IS_IPAD ? 102 : 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText = NSLocalizedString(@"AllSearchResultsHeader", @"");
    titleText = [NSString stringWithFormat:titleText, fileCount];
    TableHeaderView *tableHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35) andTitleText:titleText];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"FILE_CELL_%d_%d_%d", (int)indexPath.section, (int)indexPath.row, tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(fileList != nil && [fileList count] != 0) {
            id objAtIndex = [fileList objectAtIndex:indexPath.row];
            if([objAtIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
                
                if (fileAtIndex.contentType == ContentTypeFolder)
                    cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:searchText];
                else if (fileAtIndex.contentType == ContentTypePhoto || fileAtIndex.contentType == ContentTypeVideo)
                    cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:searchText];
                else if (fileAtIndex.contentType == ContentTypeMusic)
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:searchText];
                else if (fileAtIndex.contentType == ContentTypeDoc)
                    cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:searchText];
                else
                    cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:searchText];
                ((AbstractFileFolderCell *) cell).delegate = self;
            }
        }
        else if (fileList == nil) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ConnectionErrorWarning", @"")];
        }
        else if ([fileList count] == 0) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"NoSearchResultFound", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (fileList.count <= indexPath.row) return;
    MetaFile *fileAtIndex = [fileList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    if(fileAtIndex.contentType == ContentTypeFolder) {
        FileListController *innerList = [[FileListController alloc] initForFolder:fileAtIndex];
        innerList.nav = self.nav;
        [self.nav pushViewController:innerList animated:NO];
    } else {
        if([AppUtil isMetaFileImage:fileAtIndex]) {
            ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileAtIndex];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [self presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileDoc:fileAtIndex]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileVideo:fileAtIndex]) {
            VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileAtIndex];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [self presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileMusic:fileAtIndex]) {
            MusicPreviewController *detail = [[MusicPreviewController alloc] initWithFile:fileAtIndex.uuid withFileList:@[fileAtIndex]];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else {
            PreviewUnavailableController *detail = [[PreviewUnavailableController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        }
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    IGLog(@"SearchMoreModalController viewDidLoad");
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

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
    [shareDao requestLinkForFiles:@[fileSelected.uuid]];
    [self showLoading];
}

- (void) fileFolderCellShouldDeleteForFile:(MetaFile *)fileSelected {
    if([CacheUtil showConfirmDeletePageFlag]) {
        fileSelectedRef = fileSelected;
        if((fileSelected.addedAlbumUuids != nil && [fileSelected.addedAlbumUuids count] > 0)) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
            [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
        }
    } else {
        fileSelectedRef = fileSelected;
        ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
        confirmDelete.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    fileSelectedRef = fileSelected;
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil withExludingFolder:fileSelected.uuid withProhibitedFolders:nil];
    move.delegate = self;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    [self proceedSuccessForProgressView];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

#pragma mark ShareLinkDao Delegate Methods

- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self hideLoading];
    NSArray *activityItems = [NSArray arrayWithObjects:linkToShare, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    
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

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    
    [super showLoading];
    [searchDao requestMetadata:searchText andPage:0 andSize:NO_OF_FILES_PER_PAGE andSortType:APPDELEGATE.session.sortType andSearchListType:searchListType];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if((fileSelectedRef.addedAlbumUuids != nil && [fileSelectedRef.addedAlbumUuids count] > 0)) {
        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
        confirm.delegate = self;
        [APPDELEGATE showCustomConfirm:confirm];
    } else {
        [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    }
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    [moveDao requestMoveFiles:@[fileSelectedRef.uuid] toFolder:folderUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"MoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"MoveFailMessage", @"")];
}

#pragma mark ProcessFooterDelegate methods

- (void) processFooterShouldDismissWithButtonKey:(NSString *)postButtonKeyVal {
}

- (void) moveSuccessCallback {
    [self proceedSuccessForProgressView];
}

- (void) moveFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) cancelRequests {
    [searchDao cancelRequest];
    searchDao = nil;
    
    [loadMoreDao cancelRequest];
    loadMoreDao = nil;
    
    [favoriteDao cancelRequest];
    favoriteDao = nil;
    
    [shareDao cancelRequest];
    shareDao = nil;
    
    [moveDao cancelRequest];
    moveDao = nil;
    
    [deleteDao cancelRequest];
    deleteDao = nil;
}

@end

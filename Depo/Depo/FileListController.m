//
//  FileListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileListController.h"
#import "FolderCell.h"
#import "MusicCell.h"
#import "ImageCell.h"
#import "DocCell.h"
#import "CustomButton.h"
#import "FolderEmptyCell.h"
#import "FileDetailInWebViewController.h"
#import "AppUtil.h"
#import "ImagePreviewController.h"
#import "PreviewUnavailableController.h"
#import "UploadRef.h"
#import "UploadingImageCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "VideoPreviewController.h"
#import "BaseViewController.h"
#import "MusicPreviewController.h"

@interface FileListController ()

@end

@implementation FileListController

@synthesize folder;
@synthesize fileTable;
@synthesize refreshControl;
@synthesize fileList;
@synthesize selectedFileList;
@synthesize footerActionMenu;

- (id)initForFolder:(MetaFile *) _folder {
    self = [super init];
    if (self) {
        self.folder = _folder;
        listOffset = 0;
        
        if(self.folder) {
            self.title = self.folder.visibleName;
        } else {
            self.title = NSLocalizedString(@"FilesTitle", @"");
        }

        selectedFileList = [[NSMutableArray alloc] init];
        
        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(fileListSuccessCallback:);
        fileListDao.failMethod = @selector(fileListFailCallback:);
        
        loadMoreDao = [[FileListDao alloc] init];
        loadMoreDao.delegate = self;
        loadMoreDao.successMethod = @selector(loadMoreSuccessCallback:);
        loadMoreDao.failMethod = @selector(loadMoreFailCallback:);
        
        addFolderDao = [[AddFolderDao alloc] init];
        addFolderDao.delegate = self;
        addFolderDao.successMethod = @selector(addFolderSuccessCallback);
        addFolderDao.failMethod = @selector(addFolderFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        folderDeleteDao = [[DeleteDao alloc] init];
        folderDeleteDao.delegate = self;
        folderDeleteDao.successMethod = @selector(folderDeleteSuccessCallback);
        folderDeleteDao.failMethod = @selector(folderDeleteFailCallback:);
        
        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback:);
        favoriteDao.failMethod = @selector(favFailCallback:);
        
        folderFavDao = [[FavoriteDao alloc] init];
        folderFavDao.delegate = self;
        folderFavDao.successMethod = @selector(folderFavSuccessCallback:);
        folderFavDao.failMethod = @selector(folderFavFailCallback:);

        moveDao = [[MoveDao alloc] init];
        moveDao.delegate = self;
        moveDao.successMethod = @selector(moveSuccessCallback);
        moveDao.failMethod = @selector(moveFailCallback:);
        
        renameDao = [[RenameDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);

        fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        fileTable.delegate = self;
        fileTable.dataSource = self;
        fileTable.backgroundColor = [UIColor clearColor];
        fileTable.backgroundView = nil;
        fileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        fileTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [self.view addSubview:fileTable];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [fileTable addSubview:refreshControl];

        /* viewDidAppear'e alindi
        if(self.folder) {
            [fileListDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
        } else {
            [fileListDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
        }
        [self showLoading];
         */
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [APPDELEGATE.base immediateShowAddButton];

    [self triggerRefresh];
    [self showLoading];
}

- (void) triggerRefresh {
    listOffset = 0;
    if(self.folder) {
        [fileListDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    } else {
        [fileListDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    }
}

- (void) fileListSuccessCallback:(NSArray *) files {
    [self hideLoading];

    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    self.fileList = [[APPDELEGATE.uploadQueue uploadRefsForFolder:[self.folder uuid]] arrayByAddingObjectsFromArray:files];
    self.tableUpdateCounter ++;
    [fileTable reloadData];
}

- (void) fileListFailCallback:(NSString *) errorMessage {
    [self hideLoading];

    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) loadMoreSuccessCallback:(NSArray *) files {
    [self hideLoading];

    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    self.fileList = [fileList arrayByAddingObjectsFromArray:files];
    isLoading = NO;
//    self.tableUpdateCounter ++;
    [fileTable reloadData];
}

- (void) loadMoreFailCallback:(NSString *) errorMessage {
    [self hideLoading];

    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addFolderSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];

    listOffset = 0;
    if(self.folder) {
        [fileListDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    } else {
        [fileListDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    }
}

- (void) addFolderFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(fileList == nil) {
        return 0;
    } else if([fileList count] == 0) {
        return 1;
    } else {
        return [fileList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(fileList == nil || [fileList count] == 0) {
        return 320;
    } else {
        return 68;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"FILE_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(fileList == nil || [fileList count] == 0) {
            cell = [[FolderEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFolderTitle:self.folder.visibleName];
        } else {
            id objAtIndex = [fileList objectAtIndex:indexPath.row];
            if([objAtIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
                switch (fileAtIndex.contentType) {
                    case ContentTypeFolder:
                        cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
                        break;
                    case ContentTypePhoto:
                    case ContentTypeVideo:
                        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
                        break;
                    case ContentTypeMusic:
                        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
                        break;
                    default:
                        cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
                        break;
                }
                ((AbstractFileFolderCell *) cell).delegate = self;
            } else {
                UploadRef *refAtIndex = (UploadRef *) objAtIndex;
                cell = [[UploadingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withUploadRef:refAtIndex atFolder:[self.folder name]];
            }
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible)
        return;
    
    MetaFile *fileAtIndex = [fileList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[UploadingImageCell class]]) {
        return;
    }
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
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileDoc:fileAtIndex]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileVideo:fileAtIndex]) {
            VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileAtIndex];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = fileTable.contentOffset.y;
        CGFloat maximumOffset = fileTable.contentSize.height - fileTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    if(self.folder) {
        [loadMoreDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    } else {
        [loadMoreDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    }
}

- (void) moreClicked {
    if(self.folder) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeFolderDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.folder.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDelete], [NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]] withFileFolder:self.folder];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
}

#pragma mark AbstractFileFolderDelegate methods

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:YES];
//    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:NO];
//    [self showLoading];
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
    selectedFileList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [APPDELEGATE.base showMoveFoldersWithExludingFolder:self.folder.uuid withProhibitedFolderList:selectedFileList];
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
    if(![selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList addObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) deleteSuccessCallback {
//    [self hideLoading];
    if(isSelectible) {
        if(self.folder) {
            self.title = self.folder.visibleName;
        } else {
            self.title = NSLocalizedString(@"FilesTitle", @"");
        }
        self.navigationItem.leftBarButtonItem = previousButtonRef;
        moreButton.hidden = NO;
        
        isSelectible = NO;
        [selectedFileList removeAllObjects];
        
        if(footerActionMenu) {
            [footerActionMenu removeFromSuperview];
        }
    }

    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
//    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) folderDeleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self.nav performSelector:@selector(popViewControllerAnimated:) withObject:NO afterDelay:1.0f];
}

- (void) folderDeleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) moveSuccessCallback {
    if(isSelectible) {
        if(self.folder) {
            self.title = self.folder.visibleName;
        } else {
            self.title = NSLocalizedString(@"FilesTitle", @"");
        }
        self.navigationItem.leftBarButtonItem = previousButtonRef;
        moreButton.hidden = NO;
        
        isSelectible = NO;
        [selectedFileList removeAllObjects];
        
        if(footerActionMenu) {
            [footerActionMenu removeFromSuperview];
        }
    }
    
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) moveFailCallback:(NSString *) errorMessage {
    //    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(MetaFile *) updatedFileRef {
    [self proceedSuccessForProgressView];
    self.folder.visibleName = updatedFileRef.name;
    self.folder.lastModified = updatedFileRef.lastModified;
    self.title = self.folder.visibleName;
}

- (void) renameFailCallback:(NSString *) errorMessage {
    //    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
//    [self hideLoading];
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) favFailCallback:(NSString *) errorMessage {
//    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) folderFavSuccessCallback:(NSNumber *) favFlag {
    //    [self hideLoading];
    [[self.folder detail] setFavoriteFlag:[favFlag boolValue]];
    [self proceedSuccessForProgressView];
}

- (void) folderFavFailCallback:(NSString *) errorMessage {
    //    [self hideLoading];
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
}

- (void) newFolderModalDidTriggerNewFolderWithName:(NSString *)folderName {
    [addFolderDao requestAddFolderToParent:self.folder.uuid ? self.folder.uuid : @"" withName:folderName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FolderAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FolderAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FolderAddFailMessage", @"")];
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filePath withName:(NSString *)fileName {
    UploadRef *uploadRef = [[UploadRef alloc] init];
    uploadRef.tempUrl = filePath;
    uploadRef.fileName = fileName;
    uploadRef.contentType = ContentTypePhoto;
    
    uploadManager = [[UploadManager alloc] initWithUploadReference:uploadRef];
    [uploadManager startUploadingFile:filePath atFolder:self.folder withFileName:fileName];
    [APPDELEGATE.uploadQueue addNewUploadTask:uploadManager];
    
    fileList = [@[uploadRef] arrayByAddingObjectsFromArray:fileList];
    self.tableUpdateCounter++;
    [self.fileTable reloadData];
}

- (NSString *) appendNewFileName:(NSString *) newFileName {
    if(self.folder) {
        if([self.folder.name hasSuffix:@"/"]) {
            return [AppUtil enrichFileFolderName:[NSString stringWithFormat:@"%@%@", self.folder.name, newFileName]];
        } else {
            return [AppUtil enrichFileFolderName:[NSString stringWithFormat:@"%@/%@", self.folder.name, newFileName]];
        }
    } else {
        return [AppUtil enrichFileFolderName:newFileName];
    }
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    
    if([assetUrls count] > 0) {
        [APPDELEGATE.base showBaseLoading];
        dispatch_async(dispatch_get_main_queue(), ^{
            for(UploadRef *ref in assetUrls) {
                UploadManager *manager = [[UploadManager alloc] initWithUploadReference:ref];
                [manager startUploadingAsset:ref.filePath atFolder:self.folder];
                [APPDELEGATE.uploadQueue addNewUploadTask:manager];
            }
            fileList = [assetUrls arrayByAddingObjectsFromArray:fileList];
            self.tableUpdateCounter++;
            [self.fileTable reloadData];

            [APPDELEGATE.base hideBaseLoading];
        });
    }
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

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([cell isKindOfClass:[AbstractFileFolderCell class]]){
        AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
        if([selectedFileList containsObject:fileCell.fileFolder.uuid]) {
            [fileCell manuallyCheckButton];
        }
    }
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
    
    [selectedFileList removeAllObjects];
    
    self.tableUpdateCounter++;
    [self.fileTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
    footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    footerActionMenu.delegate = self;
    footerActionMenu.hidden = YES;
    [self.view addSubview:footerActionMenu];
}

- (void) cancelSelectible {
    if(self.folder) {
        self.title = self.folder.visibleName;
    } else {
        self.title = NSLocalizedString(@"FilesTitle", @"");
    }
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;

    isSelectible = NO;
    [selectedFileList removeAllObjects];
    
    [APPDELEGATE.base immediateShowAddButton];

    self.tableUpdateCounter++;
    [self.fileTable reloadData];

    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
}

- (void) showFooterMenu {
    footerActionMenu.hidden = NO;
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        for (NSInteger j = 0; j < [fileTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [fileTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [fileTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedFileList containsObject:fileCell.fileFolder.uuid]) {
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedFileList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base showMoveFoldersWithExludingFolder:self.folder.uuid withProhibitedFolderList:selectedFileList];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    if([selectedFileList containsObject:folderUuid]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"SelfMoveError", @"")];
        return;
    }
    [moveDao requestMoveFiles:selectedFileList toFolder:folderUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"MoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"MoveFailMessage", @"")];
}

- (void) folderDetailShouldRename:(NSString *)newNameVal {
    [renameDao requestRenameForFile:self.folder.uuid withNewName:newNameVal];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RenameFolderProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RenameFolderSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RenameFolderFailMessage", @"")];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [folderDeleteDao requestDeleteFiles:@[self.folder.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeMoreMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) moreMenuDidSelectFav {
    [folderFavDao requestMetadataForFiles:@[self.folder.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) moreMenuDidSelectUnfav {
    [folderFavDao requestMetadataForFiles:@[self.folder.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) moreMenuDidSelectShare {
    NSLog(@"At INNER moreMenuDidSelectShare");
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
    NSLog(@"At INNER confirmDeleteDidCancel");
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeFooterMenu) {
        for (NSInteger j = 0; j < [fileTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [fileTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [fileTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedFileList containsObject:fileCell.fileFolder.uuid]) {
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedFileList];
    } else if(self.deleteType == DeleteTypeMoreMenu) {
        [folderDeleteDao requestDeleteFiles:@[self.folder.uuid]];
    } else if(self.deleteType == DeleteTypeSwipeMenu) {
        [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
    }
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

@end
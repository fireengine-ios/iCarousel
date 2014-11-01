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

        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback);
        favoriteDao.failMethod = @selector(favFailCallback:);

        fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        fileTable.delegate = self;
        fileTable.dataSource = self;
        fileTable.backgroundColor = [UIColor clearColor];
        fileTable.backgroundView = nil;
        fileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:fileTable];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [fileTable addSubview:refreshControl];

        if(self.folder) {
            [fileListDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
        } else {
            [fileListDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
        }
        [self showLoading];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    self.fileList = [[APPDELEGATE.session uploadRefsForFolder:[self.folder uuid]] arrayByAddingObjectsFromArray:files];
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
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileDoc:fileAtIndex] || [AppUtil isMetaFileMusic:fileAtIndex]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileVideo:fileAtIndex]) {
            VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileAtIndex];
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
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeDetail], [NSNumber numberWithInt:MoreMenuTypeShare], [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDelete], [NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
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
    [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
//    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
    if(![selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList addObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
    } else {
        [self hideFooterMenu];
    }
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
    } else {
        [self hideFooterMenu];
    }
}

- (void) deleteSuccessCallback {
//    [self hideLoading];
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
//    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) favSuccessCallback {
//    [self hideLoading];
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) favFailCallback:(NSString *) errorMessage {
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

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filepath {
    uploadManager = [[UploadManager alloc] init];
    [uploadManager startUploadingFile:filepath atFolder:nil withFileName:@"fromCam.png"];
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
    for(UploadRef *ref in assetUrls) {
        UploadManager *manager = [[UploadManager alloc] initWithUploadReference:ref];
        [manager startUploadingAsset:ref.filePath atFolder:self.folder];
        [APPDELEGATE.session.uploadManagers addObject:manager];
    }
    fileList = [assetUrls arrayByAddingObjectsFromArray:fileList];
    self.tableUpdateCounter++;
    [self.fileTable reloadData];
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

- (void) footerActionMenuDidSelectDelete {
}

- (void) footerActionMenuDidSelectMove {
}

- (void) footerActionMenuDidSelectShare {
}

@end

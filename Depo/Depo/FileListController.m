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
#import "AppUtil.h"
#import "PreviewUnavailableController.h"
#import "UploadRef.h"
#import "UploadingImageCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import "UploadingImagePreviewController.h"
#import "MPush.h"

@interface FileListController ()

@end

@implementation FileListController

@synthesize delegate;
@synthesize folder;
@synthesize fileTable;
@synthesize refreshControl;
@synthesize fileList;
@synthesize selectedFileList;
@synthesize footerActionMenu;
@synthesize folderModificationFlag;
@synthesize uuidListToBeDeleted;
@synthesize longSelectFileUuid;

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
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);
        
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
        fileTable.isAccessibilityElement = YES;
        fileTable.accessibilityIdentifier = @"fileTableFileDetail";
        [self.view addSubview:fileTable];

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shouldMoveToSelectionState:)];
        longPressGesture.minimumPressDuration = 1.0;
        [fileTable addGestureRecognizer:longPressGesture];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [fileTable addSubview:refreshControl];

        [self triggerRefresh];
        [self showLoading];
    }
    return self;
}

- (void) shouldMoveToSelectionState:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:fileTable];
            NSIndexPath *indexPath = [fileTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                /*
                UITableViewCell *cell = [fileTable cellForRowAtIndexPath:indexPath];
                if (cell.isHighlighted) {
                    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
                        self.longSelectFileUuid = fileFolderCell.fileFolder.uuid;
                    }
                }
                 */
                [self changeToSelectedStatus];
            }
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    /*
    if(!isSelectible) {
        [self triggerRefresh];
        [self showLoading];
    }
     */
}

- (void) triggerRefresh {
    if(isSelectible) {
        [refreshControl endRefreshing];
        return;
    }
    
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
    self.fileList = [[[UploadQueue sharedInstance] uploadRefsForFolder:[self.folder uuid]] arrayByAddingObjectsFromArray:files];
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
//TODO check    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addFolderSuccessCallback {
    [self proceedSuccessForProgressView];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];

    listOffset = 0;
    if(self.folder) {
        [fileListDao requestFileListingForFolder:self.folder.uuid andForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    } else {
        [fileListDao requestFileListingForParentForPage:listOffset andSize:NO_OF_FILES_PER_PAGE sortBy:APPDELEGATE.session.sortType];
    }
}

- (void) addFolderFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
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
                UploadingImageCell *cell = [[UploadingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withUploadRef:refAtIndex atFolder:[self.folder name]];
                if (refAtIndex.hasFinished) {
                    [cell uploadManagerDidFinishUploadingForAsset:@"" withFinalFile:cell.postFile];
                    [cell updateProgressByWidth:@(self.view.frame.size.width)];
                }
                return cell;
            }
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
    
    if([cell isKindOfClass:[UploadingImageCell class]]) {
        UploadingImageCell *uploadingCell = (UploadingImageCell *) cell;
        if(uploadingCell.postFile != nil) {
            [self navigateToFileDetail:uploadingCell.postFile];
        } else {
            UploadingImagePreviewController *preview = [[UploadingImagePreviewController alloc] initWithUploadReference:uploadingCell.uploadRef withImage:uploadingCell.imgView.image];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:preview];
            preview.nav = modalNav;
            preview.oldDelegateRef = uploadingCell;
            [self.nav presentViewController:modalNav animated:YES completion:nil];
        }
        return;
    }
    if([cell isKindOfClass:[FolderEmptyCell class]]) {
        return;
    }
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }

    MetaFile *fileAtIndex = [fileList objectAtIndex:indexPath.row];
    [self navigateToFileDetail:fileAtIndex];
}

- (void) navigateToFileDetail:(MetaFile *) fileSelected {
    if(fileSelected.contentType == ContentTypeFolder) {
        FileListController *innerList = [[FileListController alloc] initForFolder:fileSelected];
        innerList.delegate = self;
        innerList.nav = self.nav;
        [self.nav pushViewController:innerList animated:NO];
    } else {
        if([AppUtil isMetaFileImage:fileSelected]) {
            ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected];
            detail.delegate = self;
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
//            [self.nav presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileDoc:fileSelected]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileSelected];
            detail.delegate = self;
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileVideo:fileSelected]) {
            VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileSelected];
            detail.delegate = self;
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
//            [self.nav presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileMusic:fileSelected]) {
            MusicPreviewController *detail = [[MusicPreviewController alloc] initWithFile:fileSelected.uuid withFileList:@[fileSelected]];
            detail.delegate = self;
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else {
            PreviewUnavailableController *detail = [[PreviewUnavailableController alloc] initWithFile:fileSelected];
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
        uuidListToBeDeleted = @[fileSelected.uuid];
        if(fileSelected.addedAlbumUuids != nil && [fileSelected.addedAlbumUuids count] > 0) {
            fileSelectedRef = fileSelected;
            self.deleteType = DeleteTypeSwipeMenu;
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
            [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
        }
    } else {
        fileSelectedRef = fileSelected;
        self.deleteType = DeleteTypeSwipeMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
    [self triggerShareForFileObjects:@[fileSelected]];
    //[APPDELEGATE.base triggerShareForFileObjects:@[fileSelected]];
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    selectedFileList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [MoreMenuView presentMoveFoldersListWithExcludingFolder:self.folder.uuid
                                       prohibitedFolderList:selectedFileList
                                             fromController:self.nav
                                              delegateOwner:self];
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

#pragma mark - Share

- (void) triggerShareForFileObjects:(NSArray *) fileList {
    if([fileList count] == 1 && ( (MetaFile *)[fileList objectAtIndex:0]).contentType == ContentTypePhoto) {
        MetaFile *tempToShare = (MetaFile *) [fileList objectAtIndex:0];
        if (!(tempToShare.contentType == ContentTypePhoto)) {
            [shareDao requestLinkForFiles:@[tempToShare.uuid]];
        } else {
            if([tempToShare isKindOfClass:[MetaFile class]]) {
                [self showLoading];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self downloadImageWithURL:[NSURL URLWithString:tempToShare.tempDownloadUrl] completionBlock:^(BOOL succeeded, UIImage *image, NSData *imageData) {
                        if (succeeded) {
                            [self hideLoading];
//                            NSArray *activityItems = [NSArray arrayWithObjects:image, nil];
                            NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempToShare.name]];
                            [imageData writeToURL:url atomically:NO];
                            
                            NSArray *activityItems = @[url];
                            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                            [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                            activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                            
                            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                [self presentViewController:activityViewController animated:YES completion:nil];
                            } else {
                                UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                                [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                            }
                        }
                    }];
                });
            }
        }
    } else {
        NSMutableArray *fileUuidList = [[NSMutableArray alloc] init];
        for(MetaFile *file in fileList) {
            [fileUuidList addObject:file.uuid];
        }
        [shareDao requestLinkForFiles:fileUuidList];
        [self showLoading];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSData *imageData))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES, image, data);
                               } else{
                                   completionBlock(NO, nil, nil);
                               }
                           }];
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
    if(uuidListToBeDeleted) {
        [APPDELEGATE.session musicFileWasDeletedWithUuids:uuidListToBeDeleted];
    }
    [self proceedSuccessForProgressView];
    [self triggerRefresh];

    self.folderModificationFlag = YES;
}

- (void) deleteFailCallback:(NSString *) errorMessage {
//    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) folderDeleteSuccessCallback {
    [self proceedSuccessForProgressView];
    if(folderModificationFlag) {
        [delegate folderWasModified];
    }
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

    self.folderModificationFlag = YES;
}

- (void) moveFailCallback:(NSString *) errorMessage {
    //    [self hideLoading];
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(MetaFile *) updatedFileRef {
    [self proceedSuccessForProgressView];
    self.folder.name = updatedFileRef.name;
    self.folder.visibleName = updatedFileRef.name;
    self.folder.lastModified = updatedFileRef.lastModified;
    self.title = self.folder.visibleName;

    self.folderModificationFlag = YES;
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

    self.folderModificationFlag = YES;
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

    IGLog(@"FileListController viewDidLoad");

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
    uploadRef.ownerPage = UploadStarterPageList;
    
    uploadManager = [[UploadManager alloc] initWithUploadInfo:uploadRef];
    [uploadManager configureUploadFileForPath:filePath atFolder:self.folder withFileName:fileName];
    [[UploadQueue sharedInstance] addNewUploadTask:uploadManager];
    
    fileList = [@[uploadRef] arrayByAddingObjectsFromArray:fileList];
    self.tableUpdateCounter++;
    [self.fileTable reloadData];

    self.folderModificationFlag = YES;

    [[CurioSDK shared] sendEvent:@"ImageCapture" eventValue:@"true"];
    [MPush hitTag:@"ImageCapture" withValue:@"true"];
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

- (void) devicePhotosDidTriggerUploadForUrls:(NSArray *)assetUrls {
    if([assetUrls count] > 0) {
        for(UploadRef *ref in assetUrls) {
            ref.ownerPage = UploadStarterPageList;
            
            UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
            [manager configureUploadAsset:ref.filePath atFolder:self.folder];
            [[UploadQueue sharedInstance] addNewUploadTask:manager];
        }
        fileList = [assetUrls arrayByAddingObjectsFromArray:fileList];
        self.tableUpdateCounter++;
        [self.fileTable reloadData];
        
        self.folderModificationFlag = YES;
    }
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    
    if([assetUrls count] > 0) {
        for(UploadRef *ref in assetUrls) {
            ref.ownerPage = UploadStarterPageList;

            UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
            [manager configureUploadAsset:ref.filePath atFolder:self.folder];
            [[UploadQueue sharedInstance] addNewUploadTask:manager];
        }
        fileList = [assetUrls arrayByAddingObjectsFromArray:fileList];
        self.tableUpdateCounter++;
        [self.fileTable reloadData];

        self.folderModificationFlag = YES;
    }
}

- (void) postUploadTrigger {
    self.tableUpdateCounter++;
    [self.fileTable reloadData];
    
    [APPDELEGATE.base hideBaseLoading];
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
    [cancelButton addTarget:self action:@selector(setToUnselectible) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedFileList removeAllObjects];
    
    if(longSelectFileUuid != nil) {
//TODO aç        [selectedFileList addObject:longSelectFileUuid];
        longSelectFileUuid = nil;
    }

    self.tableUpdateCounter++;
    [self.fileTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
    footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:NO];
    footerActionMenu.delegate = self;
    footerActionMenu.hidden = YES;
    [self.view addSubview:footerActionMenu];
}

- (void) setToUnselectible {
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
        BOOL anyInAlbum = NO;
        for (NSInteger j = 0; j < [fileTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [fileTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [fileTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedFileList containsObject:fileCell.fileFolder.uuid]) {
                        if(fileCell.fileFolder.addedAlbumUuids != nil && [fileCell.fileFolder.addedAlbumUuids count] > 0)
                            anyInAlbum = YES;
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        uuidListToBeDeleted = selectedFileList;
        if(anyInAlbum) {
            self.deleteType = DeleteTypeFooterMenu;
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            [deleteDao requestDeleteFiles:selectedFileList];
            [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
        }
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [MoreMenuView presentMoveFoldersListWithExcludingFolder:self.folder.uuid
                                       prohibitedFolderList:selectedFileList
                                             fromController:self.nav
                                              delegateOwner:self];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    MetaFile *shareObject = [[MetaFile alloc] init];
    if ([selectedFileList count] == 1) {
        for (id fileIndex in fileList) {
            if ([fileIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *tempFile = (MetaFile *) fileIndex;
                if ([tempFile.uuid isEqualToString:[selectedFileList objectAtIndex:0]]) {
                    shareObject = tempFile;
                }
            }
        }
        [self triggerShareForFileObjects:@[shareObject]];
        //[APPDELEGATE.base triggerShareForFileObjects:@[shareObject]];
    } else {
        [self triggerShareForFiles:selectedFileList];
        //[APPDELEGATE.base triggerShareForFiles:selectedFileList];
    }
}

#pragma mark - Share

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

#pragma mark - Move List Modal Delegate

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

-(void)moreMenuDidSelectFolderDetailForFolder:(MetaFile *) folder {
    [MoreMenuView presentFolderDetailForFolder:folder fromController:self.nav delegateOwner:self];
}

-(void)moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

-(void)moreMenuDidSelectSort {
    [MoreMenuView presentSortFromController:self.nav delegateOwner:self];
}

- (void) moreMenuDidSelectDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        uuidListToBeDeleted = @[self.folder.uuid];
        [folderDeleteDao requestDeleteFiles:@[self.folder.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeMoreMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
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
    if(self.folder != nil && self.folder.uuid != nil) {
        [self triggerShareForFiles:@[self.folder.uuid]];
       // [APPDELEGATE.base triggerShareForFiles:@[self.folder.uuid]];
    }
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeFooterMenu) {
        BOOL anyInAlbum = NO;
        for (NSInteger j = 0; j < [fileTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [fileTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [fileTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedFileList containsObject:fileCell.fileFolder.uuid]) {
                        if(fileCell.fileFolder.addedAlbumUuids != nil && [fileCell.fileFolder.addedAlbumUuids count] > 0)
                            anyInAlbum = YES;
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        uuidListToBeDeleted = selectedFileList;
        if(anyInAlbum) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            [deleteDao requestDeleteFiles:selectedFileList];
        }
    } else if(self.deleteType == DeleteTypeMoreMenu) {
        uuidListToBeDeleted = @[self.folder.uuid];
        [folderDeleteDao requestDeleteFiles:@[self.folder.uuid]];
    } else if(self.deleteType == DeleteTypeSwipeMenu) {
        uuidListToBeDeleted = @[fileSelectedRef.uuid];
        if(fileSelectedRef.addedAlbumUuids != nil && [fileSelectedRef.addedAlbumUuids count] > 0) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
        }
    }
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

#pragma mark FileListDelegate

- (void) folderWasModified {
    [self triggerRefresh];
    [self showLoading];
}

#pragma mark ImagePreviewDelegate methods
- (void) previewedImageWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
    [self showLoading];
}

#pragma mark VideoPreviewDelegate methods
- (void) previewedVideoWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
    [self showLoading];
}

#pragma mark MusicPreviewDelegate methods
- (void) previewedMusicWasDeleted {
    [self triggerRefresh];
    [self showLoading];
}

#pragma mark FileDetailInWebViewDelegate methods
- (void) previewedFileWasDeleted:(MetaFile *)fileDeleted {
    [self triggerRefresh];
    [self showLoading];
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    if(self.deleteType == DeleteTypeSwipeMenu) {
        uuidListToBeDeleted = @[fileSelectedRef.uuid];
        [deleteDao requestDeleteFiles:uuidListToBeDeleted];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else if(self.deleteType == DeleteTypeFooterMenu) {
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
        uuidListToBeDeleted = selectedFileList;
        [deleteDao requestDeleteFiles:selectedFileList];
    }
}

- (void) cancelRequests {
    [fileListDao cancelRequest];
    fileListDao = nil;
    
    [loadMoreDao cancelRequest];
    loadMoreDao = nil;

    [addFolderDao cancelRequest];
    addFolderDao = nil;
    
    [deleteDao cancelRequest];
    deleteDao = nil;

    [folderDeleteDao cancelRequest];
    folderDeleteDao = nil;
    
    [favoriteDao cancelRequest];
    favoriteDao = nil;

    [folderFavDao cancelRequest];
    folderFavDao = nil;

    [moveDao cancelRequest];
    moveDao = nil;

    [renameDao cancelRequest];
    renameDao = nil;
}

@end

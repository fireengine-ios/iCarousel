//
//  PhotoAlbumController.m
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbumController.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "MetaFile.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "UploadingImagePreviewController.h"
#import "PrintWebViewController.h"
#import "MPush.h"

@interface PhotoAlbumController ()

@end

@implementation PhotoAlbumController

@synthesize delegate;
@synthesize album;
@synthesize photosScroll;
@synthesize photoList;
@synthesize moreMenuView;
@synthesize selectedFileList;
@synthesize footerActionMenu;
@synthesize refreshControlPhotos;

- (id)initWithAlbum:(PhotoAlbum *) _album {
    self = [super init];
    if (self) {
        self.album = _album;
        self.view.backgroundColor = [UIColor whiteColor];

        detailDao = [[AlbumDetailDao alloc] init];
        detailDao.delegate = self;
        detailDao.successMethod = @selector(albumDetailSuccessCallback:);
        detailDao.failMethod = @selector(albumDetailFailCallback:);
        
        renameDao = [[RenameAlbumDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);
        
        deleteDao = [[DeleteAlbumsDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        deleteImgDao = [[AlbumRemovePhotosDao alloc] init];
        deleteImgDao.delegate = self;
        deleteImgDao.successMethod = @selector(deleteImgSuccessCallback:);
        deleteImgDao.failMethod = @selector(deleteImgFailCallback:);
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);
        
        albumAddPhotosDao = [[AlbumAddPhotosDao alloc] init];
        albumAddPhotosDao.delegate = self;
        albumAddPhotosDao.successMethod = @selector(photosAddedSuccessCallback);
        albumAddPhotosDao.failMethod = @selector(photosAddedFailCallback:);
        
        selectedFileList = [[NSMutableArray alloc] init];

        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid]];
        
        float mainImageHeight = self.view.frame.size.width/2;

        if(self.album.cover.detail.thumbLargeUrl) {
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mainImageHeight)];
            [bgImgView setClipsToBounds:YES];
            bgImgView.contentMode = UIViewContentModeScaleAspectFill;
            [bgImgView setImageWithURL:[NSURL URLWithString:self.album.cover.detail.thumbLargeUrl]];
            [self.view addSubview:bgImgView];
            
            UIImageView *maskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mainImageHeight)];
            maskImgView.image = [UIImage imageNamed:@"album_mask.png"];
            [self.view addSubview:maskImgView];
        } else {
            emptyBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mainImageHeight)];
            emptyBgImgView.image = [UIImage imageNamed:@"empty_album_header_bg.png"];
            [self.view addSubview:emptyBgImgView];
        }

        topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        topBgView.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        topBgView.hidden = YES;
        [self.view addSubview:topBgView];
        
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 30, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerBack) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:customBackButton];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(40, 35, self.view.frame.size.width - 80, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[UIColor whiteColor] withText:self.album.label];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];

        [self initAndSetSubTitle];
        
        moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 35, 20, 20) withImageName:@"dots_icon.png"];
        [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreButton];

        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mainImageHeight, self.view.frame.size.width, self.view.frame.size.height - mainImageHeight)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        photosScroll.userInteractionEnabled = YES ;
        photosScroll.scrollEnabled = YES;
        [self.view addSubview:photosScroll];
        
        refreshControlPhotos = [[UIRefreshControl alloc] init];
        [refreshControlPhotos addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControlPhotos];
        
        [self triggerRefresh];
    }
    return self;
}

- (void) triggerRefresh {
    for(UIView *subview in [photosScroll subviews]) {
        if([subview isKindOfClass:[SquareImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    [photoList removeAllObjects];
    [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid]];
    [self addOngoingPhotos];
    
    listOffset = 0;
    [detailDao requestDetailOfAlbum:self.album.uuid forStart:listOffset andSize:20];
}

- (void) addOngoingPhotos {
    if([photoList count] > 0) {
        int counter = 0;

        int imagePerLine = 3;
        
        float imageWidth = 100;
        float interImageMargin = 5;
        
        if(IS_IPAD) {
            imagePerLine = 5;
            imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
        }
        
        float imageTotalWidth = imageWidth + interImageMargin;

        for(UploadRef *row in photoList) {
            CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), interImageMargin + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
            SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withUploadRef:row];
            imgView.delegate = self;
            [photosScroll addSubview:imgView];
            counter ++;
        }
        photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20);
    }
}

- (void) initAndSetSubTitle {
    NSString *subTitleVal = @"";
    if(self.album.imageCount > 0 && self.album.videoCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitle", @""), self.album.imageCount, self.album.videoCount];
    } else if(self.album.imageCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitlePhotosOnly", @""), self.album.imageCount];
    } else if(self.album.videoCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitleVideosOnly", @""), self.album.videoCount];
    }
    if(!subTitleLabel) {
        subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.width/2 - 36, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor] withText:subTitleVal];
        [self.view addSubview:subTitleLabel];
    } else {
        subTitleLabel.text = subTitleVal;
    }
}

- (void) albumDetailSuccessCallback:(PhotoAlbum *) albumWithUpdatedContent {
    int counter = (int)[photoList count];

    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;

    long totalBytes = 0;
    
    if(albumWithUpdatedContent && albumWithUpdatedContent.content) {
        for(MetaFile *row in albumWithUpdatedContent.content) {
            CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), interImageMargin + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
            SquareImageView *imgView = [[SquareImageView alloc] initFinalWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
            imgView.delegate = self;
            [photosScroll addSubview:imgView];
            counter ++;
            totalBytes += row.bytes;
        }
        [photoList addObjectsFromArray:albumWithUpdatedContent.content];
    }

    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20);
    isLoading = NO;
    self.album.bytes = totalBytes;
    self.album.imageCount = albumWithUpdatedContent.imageCount;
    self.album.videoCount = albumWithUpdatedContent.videoCount;
    self.album.label = albumWithUpdatedContent.label;
    self.album.lastModifiedDate = albumWithUpdatedContent.lastModifiedDate;
    [self initAndSetSubTitle];
    
    if (refreshControlPhotos.isRefreshing) {
        [refreshControlPhotos endRefreshing];
    }

}

- (void) albumDetailFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(PhotoAlbum *) updatedAlbum {
    [self proceedSuccessForProgressView];
    self.album.label = updatedAlbum.label;
    self.album.lastModifiedDate = updatedAlbum.lastModifiedDate;
    contentModified = YES;

    titleLabel.text = [updatedAlbum label];
}

- (void) renameFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.2f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    [delegate photoAlbumDidChange:self.album.uuid];
    [self.nav popViewControllerAnimated:NO];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) photosAddedSuccessCallback {
    if([[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid] count] == 0) {
        contentModified = YES;
        [self triggerRefresh];
        [self proceedSuccessForProgressView];
    }
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    if([[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid] count] == 0) {
        contentModified = YES;
        [self triggerRefresh];
    }
//    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteImgSuccessCallback:(PhotoAlbum *) updatedAlbum {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressView];
    
    self.album.imageCount = updatedAlbum.imageCount;
    self.album.videoCount = updatedAlbum.videoCount;
    self.album.lastModifiedDate = updatedAlbum.lastModifiedDate;

    [self initAndSetSubTitle];
    contentModified = YES;
    [self triggerRefresh];
}

- (void) deleteImgFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) squareRef {
    UploadingImagePreviewController *preview = [[UploadingImagePreviewController alloc] initWithUploadReference:squareRef.uploadRef withImage:squareRef.imgView.image];
    preview.oldDelegateRef = squareRef;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:preview];
    preview.nav = modalNav;
    [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    if(fileSelected.contentType == ContentTypePhoto) {
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected withAlbum:self.album];
        detail.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
        detail.nav = modalNav;
        [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
    } else if(fileSelected.contentType == ContentTypeVideo) {
        VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileSelected withAlbum:self.album];
        detail.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
        detail.nav = modalNav;
        [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) squareImageWasLongPressedForFile:(MetaFile *)fileSelected {
    [self changeToSelectedStatus];
}

- (void) triggerBack {
    if(contentModified) {
        [delegate photoAlbumDidChange:self.album.uuid];
    }
    [self.nav popViewControllerAnimated:YES];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) triggerMore {
}

- (void) moreClicked {
    topBgView.hidden = NO;
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
        moreMenuView = nil;
    } else {
        NSArray *menuContent = @[[NSNumber numberWithInt:MoreMenuTypeAlbumDetail], [NSNumber numberWithInt:MoreMenuTypeAlbumDelete], [NSNumber numberWithInt:MoreMenuTypeSelect]];
        if(self.album.isReadOnly) {
            menuContent = @[[NSNumber numberWithInt:MoreMenuTypeAlbumDetail], [NSNumber numberWithInt:MoreMenuTypeSelect]];
        }
        moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) withList:menuContent withFileFolder:nil withAlbum:self.album];
        moreMenuView.delegate = self;
        [self.view addSubview:moreMenuView];
        [self.view bringSubviewToFront:moreMenuView];
    }
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectAlbumShare {
    [self triggerShareForFiles:@[self.album.uuid]];
}

- (void) moreMenuDidSelectAlbumDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteAlbums:@[self.album.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeMoreMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) moreMenuDidDismiss {
    topBgView.hidden = YES;
    [self performSelector:@selector(postMoreMenuDismiss) withObject:nil afterDelay:0.1f];
}

- (void) postMoreMenuDismiss {
    moreMenuView = nil;
}

#pragma mark AlbumDetailDelegate methods

- (void) albumDetailShouldRenameWithName:(NSString *)newName {
    [renameDao requestRenameAlbum:self.album.uuid withNewName:newName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumRenameProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumRenameSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumRenameFailMessage", @"")];
}

- (void) setSelectibleStatusForSquareImages:(BOOL) newStatus {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:newStatus];
        }
    }
}

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if(![selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList addObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
    } else {
        [self hideFooterMenu];
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
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

- (void) squareImageUploadFinishedForFile:(NSString *) fileUuid {
    if([[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid] count] == 0) {
        contentModified = YES;
        [self triggerRefresh];
    }
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"QuotaExceedMessage", @"")];
}

- (void) squareImageUploadLoginError:(MetaFile *)fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"LoginRequiredMessage", @"")];
}

- (void) showFooterMenu {
    if(footerActionMenu) {
        footerActionMenu.hidden = NO;
    } else {
        footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:YES];
        footerActionMenu.delegate = self;
        [self.view addSubview:footerActionMenu];
    }
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    moreButton.hidden = YES;
    
    cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(moreButton.frame.origin.x-30, moreButton.frame.origin.y, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelSelectible) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    if(!self.album.isReadOnly) {
        [APPDELEGATE.base immediateHideAddButton];
    }
    
    [selectedFileList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:YES];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    if(cancelButton) {
        [cancelButton removeFromSuperview];
    }
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    
    if(!self.album.isReadOnly) {
        [APPDELEGATE.base immediateShowAddButton];
    }
    
    [self setSelectibleStatusForSquareImages:NO];

    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
        footerActionMenu = nil;
    }
}

#pragma mark FooterMenuDelegate methods



- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        for(UIView *innerView in [photosScroll subviews]) {
            if([innerView isKindOfClass:[SquareImageView class]]) {
                SquareImageView *sqView = (SquareImageView *) innerView;
                if([selectedFileList containsObject:sqView.file.uuid]) {
                    [sqView showProgressMask];
                }
            }
        }
        [deleteImgDao requestRemovePhotos:selectedFileList fromAlbum:self.album.uuid];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        //TakingBack RemoveFromAlbum
//        [APPDELEGATE.base showConfirmRemove];
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base showPhotoAlbums];
}

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:albumUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];
    
}



- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    MetaFile *shareObject = [[MetaFile alloc] init];
    if ([selectedFileList count] == 1) {
        for (id fileIndex in photoList) {
            if ([fileIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *tempFile = (MetaFile *) fileIndex;
                if ([tempFile.uuid isEqualToString:[selectedFileList objectAtIndex:0]]) {
                    shareObject = tempFile;
                }
            }
        }
        [APPDELEGATE.base triggerShareForFileObjects:@[shareObject]];
    } else {
        [APPDELEGATE.base triggerShareForFiles:selectedFileList];
    }
    //[APPDELEGATE.base triggerShareForFiles:selectedFileList];
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
    NSMutableArray *printList = [[NSMutableArray alloc] init];
    for (int i = 0; i<[photoList count]; i++) {
        if([[photoList objectAtIndex:i] isKindOfClass:[MetaFile class]]) {
            MetaFile *tempFile = [photoList objectAtIndex:i];
            for (int j = 0;j< [selectedFileList count]; j++) {
                if ([tempFile.uuid isEqualToString:[selectedFileList objectAtIndex:j]]) {
                    if(tempFile.contentType == ContentTypePhoto){
                        [printList addObject:tempFile];
                    }
                }
            }
        }
    }
    //[printDao requestForPrintPhotos:printList];
    PrintWebViewController *printController = [[PrintWebViewController alloc] initWithUrl:@"http://akillidepo.cellograf.com/" withFileList:printList];
    printNav = [[MyNavigationController alloc] initWithRootViewController:printController];
    
    [self presentViewController:printNav animated:YES completion:nil];
    
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ConfirmDeleteModalDelegate methods


- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeMoreMenu) {
        [deleteDao requestDeleteAlbums:@[self.album.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    }
    //TakingBack RemoveFromAlbum (eklendi)
    else if(self.deleteType == DeleteTypeFooterMenu) {
        for(UIView *innerView in [photosScroll subviews]) {
            if([innerView isKindOfClass:[SquareImageView class]]) {
                SquareImageView *sqView = (SquareImageView *) innerView;
                if([selectedFileList containsObject:sqView.file.uuid]) {
                    [sqView showProgressMask];
                }
            }
        }
        [deleteImgDao requestRemovePhotos:selectedFileList fromAlbum:self.album.uuid];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RemoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RemoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RemoveFailMessage", @"")];
    }

}

//TakingBack RemoveFromAlbum
//- (void) confirmRemoveDidCancel {
//}
//
//- (void) confirmRemoveDidConfirm {
//    if(self.deleteType == DeleteTypeFooterMenu) {
//        for(UIView *innerView in [photosScroll subviews]) {
//            if([innerView isKindOfClass:[SquareImageView class]]) {
//                SquareImageView *sqView = (SquareImageView *) innerView;
//                if([selectedFileList containsObject:sqView.file.uuid]) {
//                    [sqView showProgressMask];
//                }
//            }
//        }
//        [deleteImgDao requestRemovePhotos:selectedFileList fromAlbum:self.album.uuid];
//        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RemoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RemoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RemoveFailMessage", @"")];
//    }
//}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.albumUuid = self.album.uuid;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;

        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
    contentModified = YES;
    [self triggerRefresh];
}

- (void) postUploadTrigger {
    [APPDELEGATE.base hideBaseLoading];
    contentModified = YES;
    [self triggerRefresh];
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filePath withName:(NSString *)fileName {
    UploadRef *uploadRef = [[UploadRef alloc] init];
    uploadRef.tempUrl = filePath;
    uploadRef.fileName = fileName;
    uploadRef.contentType = ContentTypePhoto;
    uploadRef.albumUuid = self.album.uuid;
    uploadRef.ownerPage = UploadStarterPagePhotos;
    uploadRef.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
    
    UploadManager *uploadManager = [[UploadManager alloc] initWithUploadInfo:uploadRef];
    [uploadManager configureUploadFileForPath:filePath atFolder:nil withFileName:fileName];
    [[UploadQueue sharedInstance] addNewUploadTask:uploadManager];
    
    contentModified = YES;
    [self triggerRefresh];

    [[CurioSDK shared] sendEvent:@"ImageCapture" eventValue:@"true"];
    [MPush hitTag:@"ImageCapture" withValue:@"true"];
}

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
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

#pragma mark ImagePreviewDelegate methods
- (void) previewedImageWasDeleted:(MetaFile *)deletedFile {
    contentModified = YES;
    [self triggerRefresh];
}

- (void) previewedVideoWasDeleted:(MetaFile *)deletedFile {
    contentModified = YES;
    [self triggerRefresh];
}

#pragma mark ScrollViewDelegate methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 111) {
        if(!isLoading) {
            CGFloat currentOffset = photosScroll.contentOffset.y;
            CGFloat maximumOffset = photosScroll.contentSize.height - photosScroll.frame.size.height;
            
            if (currentOffset - maximumOffset >= 0.0) {
                isLoading = YES;
                [self dynamicallyLoadNextPage];
            }
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [detailDao requestDetailOfAlbum:self.album.uuid forStart:listOffset andSize:20];
}

- (void) photoModalListReturnedWithSelectedList:(NSArray *)uuids {
    [albumAddPhotosDao requestAddPhotos:uuids toAlbum:self.album.uuid];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"PhotoAlbumController viewDidLoad");
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.album.isReadOnly) {
        [APPDELEGATE.base immediateHideAddButton];
    }
}

- (void)didReceiveMemoryWarning
{
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

- (void) cancelRequests {
    [detailDao cancelRequest];
    detailDao = nil;
    
    [renameDao cancelRequest];
    renameDao = nil;
    
    [deleteDao cancelRequest];
    deleteDao = nil;
    
    [deleteImgDao cancelRequest];
    deleteImgDao = nil;
    
    [shareDao cancelRequest];
    shareDao = nil;
    
    [albumAddPhotosDao cancelRequest];
    albumAddPhotosDao = nil;
}

@end

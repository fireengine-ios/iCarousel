//
//  PhotoAlbumController.m
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbumController.h"
#import "UIImageView+WebCache.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "MetaFile.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "UploadingImagePreviewController.h"
#import "PrintWebViewController.h"
#import "MPush.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareActivity.h"

@interface PhotoAlbumController ()
@property (nonatomic, copy) NSArray *fileUUIDToShare;
@property (nonatomic, copy) NSArray *fileListToShare;
@end

@implementation PhotoAlbumController

@synthesize delegate;
@synthesize album;
@synthesize photosScroll;
@synthesize photoList;
@synthesize moreMenuView;
@synthesize bgImgView;
@synthesize selectedFileList;
@synthesize footerActionMenu;
@synthesize refreshControlPhotos;
//@synthesize footerActionMenuDidSelect;


#pragma mark - Init Methods

- (id)initWithAlbum:(PhotoAlbum *) _album {
    self = [super init];
    if (self) {
        self.album = _album;
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self initDaoModels];
        selectedFileList = [[NSMutableArray alloc] init];
        self.selectedFiles = [@[] mutableCopy];
        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid]];
        
        [self reloadUI];
        [self triggerRefresh];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverPhotoDidChange) name:ALBUM_COVER_PHOTO_SET_NOTIFICATION object:nil];
    }
    return self;
}

- (id)initWithAlbumUUID:(NSString *) _albumUUID {
    self = [super init];
    if (self) {
       
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self initDaoModels];
        selectedFileList = [[NSMutableArray alloc] init];
        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid]];
        
        listOffset = 0;
        [self reloadUI];
        [detailDao requestDetailOfAlbum:_albumUUID forStart:listOffset andSize:20];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverPhotoDidChange) name:ALBUM_COVER_PHOTO_SET_NOTIFICATION object:nil];
    }
    return self;
}

- (void) initDaoModels {
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
}

#pragma mark - UI Reload

- (void) reloadUI {
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    float mainImageHeight = self.view.frame.size.width/2;
    
    if(self.album.cover.detail.thumbLargeUrl) {
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mainImageHeight)];
        [bgImgView setClipsToBounds:YES];
        bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        [bgImgView sd_setImageWithURL:[NSURL URLWithString:self.album.cover.detail.thumbLargeUrl]];
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
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(5, 30, 34, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerBack) forControlEvents:UIControlEventTouchUpInside];
    customBackButton.isAccessibilityElement = YES;
    customBackButton.accessibilityIdentifier = @"backButtonPhotoAlbum";
    [self.view addSubview:customBackButton];
    
    titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(40, 35, self.view.frame.size.width - 80, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[UIColor whiteColor] withText:self.album.label];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    [self updateHeaderViews];
    
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 35, 20, 20) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    moreButton.isAccessibilityElement = YES;
    moreButton.accessibilityIdentifier = @"moreButtonPhotoAlbum";
    [self.view addSubview:moreButton];
    
    photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mainImageHeight, self.view.frame.size.width, self.view.frame.size.height - mainImageHeight)];
    photosScroll.delegate = self;
    photosScroll.tag = 111;
    photosScroll.userInteractionEnabled = YES ;
    photosScroll.scrollEnabled = YES;
    photosScroll.alwaysBounceVertical = YES;
    [self.view addSubview:photosScroll];
    
    [self createRefreshControl];
}

-(void)createRefreshControl {
    if (!refreshControlPhotos) {
        refreshControlPhotos = [[UIRefreshControl alloc] init];
        [refreshControlPhotos addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControlPhotos];
    }
}

-(void)removeRefreshControl {
    [refreshControlPhotos removeFromSuperview];
    refreshControlPhotos = nil;
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

- (void) updateHeaderViews {
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
    
    [bgImgView sd_setImageWithURL:[NSURL URLWithString:self.album.cover.detail.thumbLargeUrl]];
}

- (void) albumDetailSuccessCallback:(PhotoAlbum *) albumWithUpdatedContent {
    if (self.album == nil) {
        self.album = [[PhotoAlbum alloc] init];
        self.album = albumWithUpdatedContent;
        [self reloadUI];
    }
    int counter = (int)[photoList count];

    int imagePerLine = 4;
    
    float imageWidth = (self.view.frame.size.width - 10) / 4;
    float interImageMargin = 2;
    
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
    
    [self updateHeaderViews];
    
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
    [self performSelector:@selector(setToUnselectible) withObject:nil afterDelay:3];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    if([[[UploadQueue sharedInstance] uploadImageRefsForAlbum:self.album.uuid] count] == 0) {
        contentModified = YES;
        [self triggerRefresh];
    }
    [self performSelector:@selector(setToUnselectible) withObject:nil afterDelay:3];
//    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteImgSuccessCallback:(PhotoAlbum *) updatedAlbum {
    if(isSelectible) {
        [self setToUnselectible];
    }
    
    [self proceedSuccessForProgressView];
    
    self.album.imageCount = updatedAlbum.imageCount;
    self.album.videoCount = updatedAlbum.videoCount;
    self.album.lastModifiedDate = updatedAlbum.lastModifiedDate;
    self.album.cover = updatedAlbum.cover;

    [self updateHeaderViews];
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
    [self.nav presentViewController:modalNav animated:YES completion:nil];
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    if(fileSelected.contentType == ContentTypePhoto || fileSelected.contentType == ContentTypeVideo) {
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected withAlbum:self.album withFiles:photoList isFileInsertedToBegining:false];
        detail.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
        detail.nav = modalNav;
        if (_isTriggeredFromSearch) {
            [self presentViewController:modalNav animated:YES completion:nil];
        } else {
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
        }
    }
}

- (BOOL) canShowAddButtonImmediately {
    return [super canShowAddButtonImmediately] && !self.album.isReadOnly;
}

- (void) squareImageWasLongPressedForFile:(MetaFile *)fileSelected {
    [self setToSelectible];
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
        NSArray *menuContent = @[[NSNumber numberWithInt:MoreMenuTypeAlbumDetail], [NSNumber numberWithInt:MoreMenuTypeAlbumShare], [NSNumber numberWithInt:MoreMenutypeDownloadAlbum], [NSNumber numberWithInt:MoreMenuTypeAlbumDelete], [NSNumber numberWithInt:MoreMenuTypeSelect]];
        if(self.album.isReadOnly) {
            menuContent = @[[NSNumber numberWithInt:MoreMenuTypeAlbumDetail], [NSNumber numberWithInt:MoreMenuTypeAlbumShare], [NSNumber numberWithInt:MoreMenutypeDownloadAlbum], [NSNumber numberWithInt:MoreMenuTypeSelect]];
        }
        moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) withList:menuContent withFileFolder:nil withAlbum:self.album];
        moreMenuView.delegate = self;
        [self.view addSubview:moreMenuView];
        [self.view bringSubviewToFront:moreMenuView];
    }
}

- (void) coverPhotoDidChange {
    [bgImgView sd_setImageWithURL:[NSURL URLWithString:self.album.cover.detail.thumbLargeUrl]];
}

#pragma mark MoreMenuDelegate

-(void)moreMenuDidSelectUpdateSelectOption {
    [self setToSelectible];
}

- (void) moreMenuDidSelectAlbumShare {
    [shareDao requestLinkForFiles:@[self.album.uuid] isAlbum:true];
    [APPDELEGATE.base showBaseLoading];
}

-(void)moreMenuDidSelectDownloadAlbum {
    [APPDELEGATE.base createAlbum:self.album withFiles:photoList  loadingMessage:NSLocalizedString(@"DownloadAlbumProgressMessage", @"")
                   successMessage:NSLocalizedString(@"DownloadAlbumSuccessMessage", @"")
                      failMessage:NSLocalizedString(@"DownloadAlbumFailMessage", @"")
     ];
    [self setToUnselectible];
}

- (void) moreMenuDidSelectAlbumDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteAlbums:@[self.album.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeMoreMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self withMessage:@"ConfirmDeleteAlbumMessage"];
//        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) moreMenuDidSelectAlbumDetailForAlbum:(PhotoAlbum *) album {
    [MoreMenuView presentAlbumDetailForAlbum:album fromController:self.nav delegateOwner:self];
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
        [self.selectedFiles addObject:fileSelected];
    }
    [self updateFooterMenuAndTitle];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
        [self.selectedFiles removeObject:fileSelected];
    }
    [self updateFooterMenuAndTitle];
}

- (void) updateFooterMenuAndTitle {
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideFooterMenu];
        titleLabel.text = NSLocalizedString(@"SelectFilesTitle", @"");
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
        footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:NO shouldShowRemove:YES shouldShowDownload:YES shouldShowPrint:YES];
        //footerActionMenu = [[FooterActionsMenuView alloc] initForPhotosTabWithFrame:frame shouldShowShare:YES shouldShowMove:YES shouldShowDownload:YES shouldShowDelete:YES shouldShowPrint:YES isMoveAlbum:NO];
       // footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:YES];
        footerActionMenu.delegate = self;
        [self.view addSubview:footerActionMenu];
    }
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

- (void) setToSelectible {
    isSelectible = YES;
    [self removeRefreshControl];
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    moreButton.hidden = YES;
    
    cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(moreButton.frame.origin.x-30, moreButton.frame.origin.y, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(setToUnselectible) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.isAccessibilityElement = YES;
    cancelButton.accessibilityIdentifier = @"cancelButtonPhotoAlbum";
    [self.view addSubview:cancelButton];
    
    if(!self.album.isReadOnly) {
        [APPDELEGATE.base immediateHideAddButton];
    }
    
    [selectedFileList removeAllObjects];
    [self.selectedFiles removeAllObjects];
    [self setSelectibleStatusForSquareImages:YES];
}

- (void) setToUnselectible {
    titleLabel.text = album.label;
//    self.title = NSLocalizedString(@"PhotosTitle", @"");
    if(cancelButton) {
        [cancelButton removeFromSuperview];
    }
    moreButton.hidden = NO;
    
    isSelectible = NO;
     [self createRefreshControl];
    [selectedFileList removeAllObjects];
    [self.selectedFiles removeAllObjects];
    if(!self.album.isReadOnly && !footerActionMenuDidSelect) {
        [APPDELEGATE.base immediateShowAddButton];
    }
    
    footerActionMenuDidSelect = NO;
    
    [self setSelectibleStatusForSquareImages:NO];

    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
        footerActionMenu = nil;
    }
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDownload:(FooterActionsMenuView *) menu {
    NSString *loadingMessage = NSLocalizedString(@"DownloadImagesProgressMessage", @"");
    NSString *failMessage = NSLocalizedString(@"DownloadImagesFailMessage", @"");
    NSString *successMessage = NSLocalizedString(@"DownloadImagesSuccessMessage", @"");
    APPDELEGATE.base.isVideosAlbum = self.album.isReadOnly;
    [APPDELEGATE.base downloadFilesToCameraRoll:[self getMetaFilesOfSelectedFiles]
                                 loadingMessage:loadingMessage
                                 successMessage:successMessage
                                    failMessage:failMessage];
    footerActionMenuDidSelect = YES;
    [self setToUnselectible];
}

-(NSMutableArray *)getMetaFilesOfSelectedFiles {
    NSMutableArray *array = [NSMutableArray array];
    for (MetaFile *file in photoList) {
        for (NSString *uuid in selectedFileList) {
            if ([uuid isEqualToString:file.uuid]) {
                [array addObject:file];
            }
        }
    }
    return array;
}

- (void) footerActionMenuDidSelectRemove:(FooterActionsMenuView *) menu {
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
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RemoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RemoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RemoveFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [MoreMenuView presentConfirmRemoveFromController:self.nav delegateOwner:self];
    }
    footerActionMenuDidSelect = YES;
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [MoreMenuView presentPhotoAlbumsFromController:self.nav delegateOwner:self];
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
        [self triggerShareForFileObjects:@[shareObject]];
        //[APPDELEGATE.base triggerShareForFileObjects:@[shareObject]];
    } else {
        [self triggerShareForFiles:self.selectedFiles withUUID:selectedFileList];
        //[APPDELEGATE.base triggerShareForFiles:selectedFileList];
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
    
    [self.nav presentViewController:printNav animated:YES completion:nil];
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

- (void)showLoading {
    [self.progress removeFromSuperview];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self.progress];
    [self.progress show:YES];
}

- (void)hideLoading {
    [self.progress hide:YES];
    [self.progress removeFromSuperview];
    [self.view insertSubview:self.progress atIndex:0];
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
                            
//                            BOOL thisIsAnImage = tempToShare.contentType == ContentTypePhoto;
                            
                            NSArray *applicationActivities = nil;
//                            if (thisIsAnImage) {
                                ShareActivity *activity = [[ShareActivity alloc] init];
                                activity.sourceViewController = self;
                                
                                applicationActivities = @[activity];
//                            } else {
//                                activityItems = @[@"#lifebox", url];
//                            }
                            
                            UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                                                initWithActivityItems:activityItems
                                                                                applicationActivities:applicationActivities];
                            [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                            activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//                            if (thisIsAnImage) {
                                activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
//                            }
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
    [self setToUnselectible];
    [APPDELEGATE.base hideBaseLoading];
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
    [APPDELEGATE.base hideBaseLoading];
}



#pragma mark ConfirmDeleteModalDelegate methods


- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeMoreMenu) {
        [deleteDao requestDeleteAlbums:@[self.album.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    }
}

- (void) confirmRemoveDidCancel {
}

- (void) confirmRemoveDidConfirm {
    if(self.deleteType == DeleteTypeFooterMenu) {
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

- (void) devicePhotosDidTriggerUploadForUrls:(NSArray *)assetUrls {
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

- (void) triggerShareForFiles:(NSArray *)fileList withUUID:(NSArray *) fileUuidList {
//    [shareDao requestLinkForFiles:fileUuidList];
//    [self showLoading];
    self.fileUUIDToShare = fileUuidList;
    self.fileListToShare = self.selectedFiles;
    [self presentSharePopup];
}

- (void)presentSharePopup {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButtonTittle", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"ShareSmallSize", nil),
                                  NSLocalizedString(@"ShareOriginalSize", nil),
                                  NSLocalizedString(@"ShareViaLink", nil),
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self shareImageFiles:NO];
            break;
        case 1:
            [self shareImageFiles:YES];
            break;
        case 2:
            [shareDao requestLinkForFiles:self.fileUUIDToShare];
            break;
        default:
            break;
    }
}

- (void)shareImageFiles:(BOOL)originalSize {
    //    __block NSInteger imagesCount = fileUuidList.count;
    __block NSMutableArray *allImages = [@[] mutableCopy];
    
    [self showLoading];
    
//    BOOL thereIsOneVideo = NO;
    
    for (MetaFile *file in self.fileListToShare) {
        NSString *endPoint = file.detail.thumbLargeUrl;
        if (originalSize) {
            endPoint = file.tempDownloadUrl;
        }
        if (file.contentType == ContentTypeVideo) {
            endPoint = file.tempDownloadUrl;
//            thereIsOneVideo = YES;
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:endPoint]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (!error) {
                                       if (file.contentType == ContentTypeVideo) {
                                           NSURL *url = [NSURL fileURLWithPath:
                                                         [NSTemporaryDirectory() stringByAppendingString:file.name]];
                                           [data writeToURL:url atomically:NO];
                                           [allImages addObject:url];
                                       } else {
                                           if (originalSize) {
                                               NSURL *url = [NSURL fileURLWithPath:
                                                             [NSTemporaryDirectory() stringByAppendingString:file.name]];
                                               [data writeToURL:url atomically:NO];
                                               [allImages addObject:url];
                                           } else {
                                               UIImage *image = [[UIImage alloc] initWithData:data];
                                               [allImages addObject:image];
                                           }
                                       }
                                       if (allImages.count == self.fileListToShare.count) {
                                           NSLog(@"downloaded all images to share");
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self hideLoading];
                                               
                                               NSArray *applicationActivities = nil;
                                               
//                                               if (!thereIsOneVideo) {
                                                   ShareActivity *activity = [[ShareActivity alloc] init];
                                                   activity.sourceViewController = self;
                                                   applicationActivities = @[activity];
//                                               } else {
//                                                   [allImages insertObject:@"#lifebox" atIndex:0];
//                                               }
                                               
                                               UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:allImages applicationActivities:applicationActivities];
                                               [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                                               activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//                                               if (!thereIsOneVideo) {
                                                   activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
//                                               }
                                               [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                                                   if (completed) {
                                                       [self setToUnselectible];
                                                   }
                                               }];
                                               
                                               if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                                   [self presentViewController:activityViewController animated:YES completion:nil];
                                               } else {
                                                   UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                                                   [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                                               }
                                           });
                                       }
                                   } else{
                                   }
                               }];
    }
    
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
    if(self.album.isReadOnly) {
        [APPDELEGATE.base immediateHideAddButton];
    }
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
//    if(self.album.isReadOnly) {
//        [APPDELEGATE.base immediateHideAddButton];
//    }
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

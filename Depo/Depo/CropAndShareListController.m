//
//  CropAndShareListController.m
//  Depo
//
//  Created by Mahir on 09/11/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "CropAndShareListController.h"
#import "PreviewUnavailableController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import "MapUtil.h"
#import "UploadingImagePreviewController.h"
#import "PrintWebViewController.h"
#import "MPush.h"
#import "ShareActivity.h"

@interface CropAndShareListController ()

@end

@implementation CropAndShareListController

@synthesize photosScroll;
@synthesize photoList;
@synthesize refreshControlPhotos;
@synthesize selectedFileList;
@synthesize imgFooterActionMenu;
@synthesize photoCount;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"CropAndShareTitle", @"");
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        photoCount = 0;
        
        selectedFileList = [[NSMutableArray alloc] init];
        
        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefs]];
        
        normalizedContentHeight = self.view.frame.size.height - self.bottomIndex - 50;
        maximizedContentHeight = self.view.frame.size.height - self.bottomIndex + 14;
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];
        
//        [self addOngoingPhotos];
        
        refreshControlPhotos = [[UIRefreshControl alloc] init];
        [refreshControlPhotos addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControlPhotos];
        
        [self triggerRefresh];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [APPDELEGATE.base dismissAddButton];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

- (void) addOngoingPhotos {
    if (noItemCell != nil)
        [noItemCell removeFromSuperview];
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
            CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
            SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withUploadRef:row];
            imgView.delegate = self;
            [photosScroll addSubview:imgView];
            counter ++;
        }
        float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
        if(contentSizeHeight <= photosScroll.frame.size.height) {
            contentSizeHeight = photosScroll.frame.size.height + 1;
        }
        photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    }
}

- (void) setSelectibleStatusForSquareImages:(BOOL) newStatus {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:newStatus];
        }
    }
}

- (void) triggerRefresh {
    [photoList removeAllObjects];
    if (isSelectible) {
        [selectedFileList removeAllObjects];
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
//    [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefs]];
//    [self addOngoingPhotos];
    
    listOffset = 0;
    self.tableUpdateCounter ++;
    
    [elasticSearchDao requestCropNShareForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];

    int imagePerLine = 4;
    
    float imageWidth = (self.view.frame.size.width - 10) / 4;
    float interImageMargin = 2;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;

    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    [photoList addObjectsFromArray:files];
    if (photoList.count == 0) {
        if (noItemCell == nil)
            noItemCell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemCell];
    }
    else if (noItemCell != nil)
        [noItemCell removeFromSuperview];
    if(refreshControlPhotos) {
        [refreshControlPhotos endRefreshing];
    }
    isLoading = NO;
    
    if([photoList count] == 0) {
        APPDELEGATE.session.user.cropAndSharePresentFlag = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:CROPY_EMPTY_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void) alignPhotosScrollPostDelete {
    NSMutableArray *filteredFiles = [[NSMutableArray alloc] init];
    NSMutableArray *ongoingFiles = [[NSMutableArray alloc] init];
    for(id row in photoList) {
        if([row isKindOfClass:[MetaFile class]]) {
            MetaFile *file = (MetaFile *) row;
            if(![selectedFileList containsObject:file.uuid]) {
                [filteredFiles addObject:row];
            }
        } else {
            [ongoingFiles addObject:row];
        }
    }
    
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            if(((SquareImageView *) subView).uploadRef == nil) {
                [subView removeFromSuperview];
            }
        }
    }
    
    int counter = (int)[ongoingFiles count];

    int imagePerLine = 3;
    
    float imageWidth = (self.view.frame.size.width - 20) / 3;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;

    for(MetaFile *row in filteredFiles) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    
    self.photoList = ongoingFiles;
    [photoList addObjectsFromArray:filteredFiles];
    
    if (photoList.count == 0) {

        APPDELEGATE.session.user.cropAndSharePresentFlag = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:CROPY_EMPTY_NOTIFICATION object:nil userInfo:nil];

        if (noItemCell == nil)
            noItemCell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemCell];
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteSuccessCallback {
    [self alignPhotosScrollPostDelete];
    
    if(isSelectible) {
        [self setToUnselectible];
    }
    
    [self proceedSuccessForProgressView];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
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
        NSMutableArray *filteredPhotoList = [[NSMutableArray alloc] init];
        for(id file in photoList) {
            if([file isKindOfClass:[MetaFile class]]) {
                [filteredPhotoList addObject:file];
            }
        }
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFiles:photoList withImage:fileSelected withListOffset:listOffset printEnabled:YES isFileInsertedToBegining:false];
        detail.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
        detail.nav = modalNav;
        [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
    } else if(fileSelected.contentType == ContentTypeVideo) {
        VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileSelected];
        detail.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
        detail.nav = modalNav;
        [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
    if (fileSelected.contentType == ContentTypeVideo) {
        if (photoCount == 0) {
            [imgFooterActionMenu hidePrintIcon];
        }
        else{
            [imgFooterActionMenu showPrintIcon];
        }
    }
    else {
        photoCount++;
        [imgFooterActionMenu showPrintIcon];
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
    if (fileSelected.contentType == ContentTypePhoto) {
        photoCount--;
    }
    if (photoCount == 0) {
        [imgFooterActionMenu hidePrintIcon];
    }
}

- (BOOL) checkIfSelectedFileListContainsPhoto {
    if (photoCount > 0) {
        return YES;
    }
    else {
        return NO;
    }
}


- (void) squareImageUploadFinishedForFile:(NSString *) fileUuid {
    if([[[UploadQueue sharedInstance] uploadImageRefs] count] == 0) {
        [self triggerRefresh];
    }
}

- (void) squareImageWasLongPressedForFile:(MetaFile *)fileSelected {
    [self changeToSelectedStatus];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"QuotaExceedMessage", @"")];
}

- (void) squareImageUploadLoginError:(MetaFile *)fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"LoginRequiredMessage", @"")];
}

- (void) showImgFooterMenu {
    if(imgFooterActionMenu) {
        imgFooterActionMenu.hidden = NO;
    } else {
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:NO isMoveAlbum:YES];
        imgFooterActionMenu.delegate = self;
        [self.view addSubview:imgFooterActionMenu];
    }
}

- (void) hideImgFooterMenu {
    imgFooterActionMenu.hidden = YES;
}

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
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView];
    if(translation.y > 0) {
        // isNavigationBarHidden kontrolü özellikle eklendi. Bu kontrol olmadan pull to refresh eziliyordu.
        if([self.nav isNavigationBarHidden]) {
            [self.nav showNavigationBar];
            photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
        }
    } else {
        [self.nav hideNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, maximizedContentHeight);
    }
    if(imgFooterActionMenu) {
        imgFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(self.processView) {
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestCropNShareForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nav showNavigationBar];
    
    photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
}

- (void) devicePhotosDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
    [self triggerRefresh];
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
    [self triggerRefresh];
}

- (void) postUploadTrigger {
    [APPDELEGATE.base hideBaseLoading];
    [self triggerRefresh];
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filePath withName:(NSString *)fileName {
    UploadRef *uploadRef = [[UploadRef alloc] init];
    uploadRef.tempUrl = filePath;
    uploadRef.fileName = fileName;
    uploadRef.contentType = ContentTypePhoto;
    uploadRef.ownerPage = UploadStarterPagePhotos;
    uploadRef.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
    
    UploadManager *uploadManager = [[UploadManager alloc] initWithUploadInfo:uploadRef];
    [uploadManager configureUploadFileForPath:filePath atFolder:nil withFileName:fileName];
    [[UploadQueue sharedInstance] addNewUploadTask:uploadManager];
    
    [self triggerRefresh];

    [[CurioSDK shared] sendEvent:@"ImageCapture" eventValue:@"true"];
    [MPush hitTag:@"ImageCapture" withValue:@"true"];
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
}

#pragma mark - More Menu Delegate

-(void)moreMenuDidSelectSort {
    [MoreMenuView presentSortFromController:self.nav delegateOwner:self];
}

- (void) moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    previousButtonRef = self.navigationItem.leftBarButtonItem;
    
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedFileList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:YES];
}

- (void) cancelClicked {
    [self setToUnselectible];
}

- (void) setToUnselectible {
    self.title = NSLocalizedString(@"CropAndShareTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:NO];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }
}

#pragma mark ImagePreviewDelegate methods
- (void) previewedImageWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
}

#pragma mark VideoPreviewDelegate methods
- (void) previewedVideoWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
}

#pragma mark PhotoAlbumDelegate methods
- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [self triggerRefresh];
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
        
        [deleteDao requestDeleteFiles:selectedFileList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypePhotos;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [MoreMenuView presentPhotoAlbumsFromController:self.nav delegateOwner:self];
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
        [self triggerShareForFiles:selectedFileList];
       // [APPDELEGATE.base triggerShareForFiles:selectedFileList];
    }
}

#pragma mark - Share


- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

- (void) triggerShareForFileObjects:(NSArray *) fileList {
    if([fileList count] == 1 && ( (MetaFile *)[fileList objectAtIndex:0]).contentType == ContentTypePhoto) {
        MetaFile *tempToShare = (MetaFile *) [fileList objectAtIndex:0];
        if (!(tempToShare.contentType == ContentTypePhoto)) {
            [shareDao requestLinkForFiles:@[tempToShare.uuid]];
        } else {
            if([tempToShare isKindOfClass:[MetaFile class]]) {
                [self showLoading];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self downloadImageWithURL:[NSURL URLWithString:tempToShare.tempDownloadUrl]
                               completionBlock:
                     ^(BOOL succeeded, UIImage *image, NSData *imageData) {
                        if (succeeded) {
                            [self hideLoading];
                            
                            NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempToShare.name]];
                            [imageData writeToURL:url atomically:NO];
                            
                            BOOL thisIsAnImage = tempToShare.contentType == ContentTypePhoto;
                            
                            NSArray *applicationActivities = nil;
                            NSArray *activityItems = @[url];
                            
                            if (thisIsAnImage) {
                                ShareActivity *activity = [[ShareActivity alloc] init];
                                activity.sourceViewController = self;
                                
                                applicationActivities = @[activity];
                            } else {
                                activityItems = @[@"#lifebox", url];
                            }
                            
                            UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                                                initWithActivityItems:activityItems
                                                                                applicationActivities:applicationActivities];
                            [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"")
                                                  forKeyPath:@"subject"];
                            activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                            if (thisIsAnImage) {
                                activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
                            }
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
    NSArray *activityItems = [NSArray arrayWithObjects:
                              [NSURL URLWithString:linkToShare], nil];
    
    ShareActivity *activity = [[ShareActivity alloc] init];
    activity.sourceViewController = self;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:@[activity]];
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"")
                          forKeyPath:@"subject"];
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
    
    [self presentViewController:printNav animated:YES completion:nil];    //[self.nav presentViewController:printController animated:YES completion:nil];
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            if([selectedFileList containsObject:sqView.file.uuid]) {
                [sqView showProgressMask];
            }
        }
    }
    
    [deleteDao requestDeleteFiles:selectedFileList];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    IGLog(@"CropAndShareListController viewDidLoad");

    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
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

@end

//
//  PhotoListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoListController.h"
#import "PreviewUnavailableController.h"
#import "PhotoAlbum.h"
#import "MainPhotoAlbumCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import "MapUtil.h"
#import "UploadingImagePreviewController.h"
#import "PrintWebViewController.h"
#import "UIImageView+WebCache.h"
#import "NoItemView.h"
#import "MPush.h"
#import "ShareActivity.h"

#define IMG_FOOTER_TAG 111
#define ALBUM_FOOTER_TAG 222

@interface PhotoListController ()

@end

@implementation PhotoListController

@synthesize headerView;
@synthesize photosScroll;
@synthesize photoList;
@synthesize refreshControlPhotos;
@synthesize refreshControlAlbums;
@synthesize albumList;
@synthesize albumTable;
@synthesize selectedFileList;
@synthesize selectedAlbumList;
@synthesize imgFooterActionMenu;
@synthesize albumFooterActionMenu;
@synthesize photoCount;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);
        
        albumListDao = [[AlbumListDao alloc] init];
        albumListDao.delegate = self;
        albumListDao.successMethod = @selector(albumListSuccessCallback:);
        albumListDao.failMethod = @selector(albumListFailCallback:);
        
        addAlbumDao = [[AddAlbumDao alloc] init];
        addAlbumDao.delegate = self;
        addAlbumDao.successMethod = @selector(addAlbumSuccessCallback);
        addAlbumDao.failMethod = @selector(addAlbumFailCallback:);

        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        deleteAlbumDao = [[DeleteAlbumsDao alloc] init];
        deleteAlbumDao.delegate = self;
        deleteAlbumDao.successMethod = @selector(deleteAlbumSuccessCallback);
        deleteAlbumDao.failMethod = @selector(deleteAlbumFailCallback:);

        albumAddPhotosDao = [[AlbumAddPhotosDao alloc] init];
        albumAddPhotosDao.delegate = self;
        albumAddPhotosDao.successMethod = @selector(photosAddedSuccessCallback);
        albumAddPhotosDao.failMethod = @selector(photosAddedFailCallback:);
        
        photoCount = 0;
        
        selectedFileList = [[NSMutableArray alloc] init];
        selectedAlbumList = [[NSMutableArray alloc] init];

        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefs]];
        
        normalizedContentHeight = self.view.frame.size.height - self.bottomIndex - 50;
        maximizedContentHeight = self.view.frame.size.height - self.bottomIndex + 14;
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex + 50, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];
        
        [self addOngoingPhotos];

        refreshControlPhotos = [[UIRefreshControl alloc] init];
        [refreshControlPhotos addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControlPhotos];
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 50, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
//        albumTable.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        albumTable.tag = 222;
        albumTable.hidden = YES;
        albumTable.isAccessibilityElement = YES;
        albumTable.accessibilityIdentifier = @"albumTablePhotoList";
        [self.view addSubview:albumTable];

        refreshControlAlbums = [[UIRefreshControl alloc] init];
        [refreshControlAlbums addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [albumTable addSubview:refreshControlAlbums];

        headerView = [[PhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        headerView.delegate = self;
        [self.view addSubview:headerView];

        [self triggerRefresh];

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectionStateForAlbums:)];
        longPressGesture.minimumPressDuration = 1.0;
        [albumTable addGestureRecognizer:longPressGesture];
    
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(!albumTable.hidden) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    }
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

    /*
    listOffset = 0;
     [elasticSearchDao requestPhotosAndVideosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
    [albumListDao requestAlbumListForStart:0 andSize:50];
    [self showLoading];
     */
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

- (void) addOngoingPhotos {
    if (noItemView != nil)
        [noItemView removeFromSuperview];
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

- (void) selectionStateForAlbums:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:albumTable];
            NSIndexPath *indexPath = [albumTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                UITableViewCell *cell = [albumTable cellForRowAtIndexPath:indexPath];
                if (cell.isHighlighted) {
                    [self changeToSelectedStatus];
                }
            }
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
    
    [photoList addObjectsFromArray:[[UploadQueue sharedInstance] uploadImageRefs]];
    [self addOngoingPhotos];

    listOffset = 0;
    self.tableUpdateCounter ++;

    [elasticSearchDao requestPhotosAndVideosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];

    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
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
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
    else if (noItemView != nil)
        [noItemView removeFromSuperview];
    if(refreshControlPhotos) {
        [refreshControlPhotos endRefreshing];
    }
    if(refreshControlAlbums) {
        [refreshControlAlbums endRefreshing];
    }
    isLoading = NO;
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
    
    float imageWidth = 100;
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
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albumList = list;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addAlbumSuccessCallback {
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
    
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
}

- (void) deleteSuccessCallback {
    [self alignPhotosScrollPostDelete];

    if(isSelectible) {
        [self setToUnselectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
//    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteAlbumSuccessCallback {
    if(isSelectible) {
        [self setToUnselectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];

    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) deleteAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photosAddedSuccessCallback {
    if(isSelectible) {
        [self setToUnselectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    
    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

    albumTable.hidden = NO;
    photosScroll.hidden = YES;

    if(isSelectible) {
        [self hideImgFooterMenu];
        if([selectedAlbumList count] > 0) {
            [self showAlbumFooterMenu];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
        } else {
            [self hideAlbumFooterMenu];
            self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
        }
    }
}

- (void) photoHeaderDidSelectPhotosSegment {
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

    albumTable.hidden = YES;
    photosScroll.hidden = NO;

    if(isSelectible) {
        [self hideAlbumFooterMenu];
        if([selectedFileList count] > 0) {
            [self showImgFooterMenu];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
        } else {
            [self hideImgFooterMenu];
            self.title = NSLocalizedString(@"SelectFilesTitle", @"");
        }
    }
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
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFiles:filteredPhotoList withImage:fileSelected withListOffset:listOffset isFileInsertedToBegining:false];
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
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:YES isMoveAlbum:YES];
        imgFooterActionMenu.tag = IMG_FOOTER_TAG;
        imgFooterActionMenu.delegate = self;
        [self.view addSubview:imgFooterActionMenu];
    }
}

- (void) hideImgFooterMenu {
    imgFooterActionMenu.hidden = YES;
}

- (void) showAlbumFooterMenu {
    if(albumFooterActionMenu) {
        albumFooterActionMenu.hidden = NO;
    } else {
        albumFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES shouldShowPrint:NO];
        albumFooterActionMenu.tag = ALBUM_FOOTER_TAG;
        albumFooterActionMenu.delegate = self;
        [self.view addSubview:albumFooterActionMenu];
    }
}

- (void) hideAlbumFooterMenu {
    albumFooterActionMenu.hidden = YES;
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
            albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
        }
    } else {
        [self.nav hideNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, maximizedContentHeight);
        albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, maximizedContentHeight);
    }
    if(imgFooterActionMenu) {
        imgFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(albumFooterActionMenu) {
        albumFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(self.processView) {
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (void)sscrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
    
    if(velocity.y > 0) {
        [self.nav showNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
        albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
    } else {
        [self.nav hideNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, maximizedContentHeight);
        albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, maximizedContentHeight);
    }
    if(imgFooterActionMenu) {
        imgFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(albumFooterActionMenu) {
        albumFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(self.processView) {
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestPhotosAndVideosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width/2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (albumList.count == 0)
        return 1;
    return [albumList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ALBUM_MAIN_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if (albumList.count > 0) {
            PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
            cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album isSelectible:isSelectible];
        }
        else
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_album_icon" titleText:NSLocalizedString(@"EmptyAlbumsTitle", @"") descriptionText:NSLocalizedString(@"EmptyAlbumsDescription", @"")];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(albumList == nil || [albumList count] == 0) {
        return;
    }
    
    PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
    if(isSelectible) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[MainPhotoAlbumCell class]]) {
            if(![selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList addObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
                [self showAlbumFooterMenu];
                self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
            } else {
                [self hideAlbumFooterMenu];
                self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
            }
        }
    } else {
        PhotoAlbumController *albumController = [[PhotoAlbumController alloc] initWithAlbum:album];
        albumController.delegate = self;
        albumController.nav = self.nav;
        [self.nav pushViewController:albumController animated:NO];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible) {
        if(!albumList || [albumList count] == 0) {
            return;
        }
        if([albumList count] > indexPath.row) {
            PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
            if([selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList removeObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
                [self showAlbumFooterMenu];
                self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
            } else {
                [self hideAlbumFooterMenu];
                self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
            }
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nav showNavigationBar];

    photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
    albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
    [addAlbumDao requestAddAlbumWithName:albumName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumAddFailMessage", @"")];
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
    if(albumTable.isHidden) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSortWithList], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
}

#pragma mark - More Menu Delegate

-(void)moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

- (void) moreMenuDidSelectSortWithList {
    NSArray *list = [NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeAlphaAsc], [NSNumber numberWithInt:SortTypeAlphaDesc], [NSNumber numberWithInt:SortTypeDateAsc], [NSNumber numberWithInt:SortTypeDateDesc], nil];
    [MoreMenuView presnetSortWithList:list fromController:self.nav delegateOwner:self];
}

-(void)moreMenuDidSelectSort {
    [MoreMenuView presentSortFromController:self.nav delegateOwner:self];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    if(albumTable.isHidden) {
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    } else {
        self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
    }

    previousButtonRef = self.navigationItem.leftBarButtonItem;
    
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedFileList removeAllObjects];
    [selectedAlbumList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:YES];
    
    albumTable.allowsMultipleSelection = YES;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) cancelClicked {
    [self setToUnselectible];
    [APPDELEGATE.base immediateShowAddButton];
}

- (void) setToUnselectible {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    [selectedAlbumList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:NO];
    
    albumTable.allowsMultipleSelection = NO;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }
    if(albumFooterActionMenu) {
        [albumFooterActionMenu removeFromSuperview];
        albumFooterActionMenu = nil;
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
    [APPDELEGATE.base immediateShowAddButton];
    [self triggerRefresh];
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        if(menu.tag == IMG_FOOTER_TAG) {
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
            [deleteAlbumDao requestDeleteAlbums:selectedAlbumList];
            [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
        }
    } else {
        if(menu.tag == IMG_FOOTER_TAG) {
            self.deleteType = DeleteTypePhotos;
        } else {
            self.deleteType = DeleteTypeAlbums;
        }
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
       // [APPDELEGATE.base triggerShareForFileObjects:@[shareObject]];
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

- (void) triggerShareForFileObjects:(NSArray *) fileList {
    if([fileList count] == 1 && ( (MetaFile *)[fileList objectAtIndex:0]).contentType == ContentTypePhoto) {
        MetaFile *tempToShare = (MetaFile *) [fileList objectAtIndex:0];
        if (!(tempToShare.contentType == ContentTypePhoto)) {
            [shareDao requestLinkForFiles:@[tempToShare.uuid]];
        } else {
            if([tempToShare isKindOfClass:[MetaFile class]]) {
                [self loadView];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self downloadImageWithURL:[NSURL URLWithString:tempToShare.tempDownloadUrl] completionBlock:^(BOOL succeeded, UIImage *image, NSData *imageData) {
                        if (succeeded) {
                            [self hideLoading];
//                            NSArray *activityItems = [NSArray arrayWithObjects:image, nil];
                            
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
                            [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
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

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:albumUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];

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
    if(self.deleteType == DeleteTypePhotos) {
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
    } else if(self.deleteType == DeleteTypeAlbums) {
        [deleteAlbumDao requestDeleteAlbums:selectedAlbumList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"PhotoListController viewDidLoad");
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

- (void) dealloc {
    //mahir
//    [UIImageView clearImageCaches];
}

@end

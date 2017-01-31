//
//  ImagePreviewController.m
//  Depo
//
//  Created by Mahir on 10/5/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ImagePreviewController.h"
#import "Util.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "PrintWebViewController.h"
#import "AppUtil.h"
#import "TutorialView.h"

@interface ImagePreviewController ()

@end

@implementation ImagePreviewController

@synthesize delegate;
@synthesize file;
@synthesize files;
@synthesize cursor;
@synthesize album;

- (id)initWithFile:(MetaFile *) _file {
    return [self initWithFile:_file withAlbum:nil];
}

- (id)initWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum *) _album {
    self = [super init];
    if (self) {
        [self configureWithFile:_file withAlbum:_album];
    }
    return self;
}

#pragma mark - Added For Swipe Feature

- (id)initWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum *) _album withFiles:(NSArray *)_files withListOffset:(int)offset {
    self = [super init];
    if (self) {
        [self configureWithFile:_file withAlbum:_album];
        self.files = [_files mutableCopy];
        cursor = [self findCursorValue];
        listOffSet = offset;
        [self addSwipeGestures];
    }
    return self;
}

-(void)configureWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum *) _album {
    self.file = _file;
    self.title = self.file.visibleName;
    self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];
    self.album = _album;
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    deleteDao = [[DeleteDao alloc] init];
    deleteDao.delegate = self;
    deleteDao.successMethod = @selector(deleteSuccessCallback);
    deleteDao.failMethod = @selector(deleteFailCallback:);
    
    removeDao = [[AlbumRemovePhotosDao alloc] init];
    removeDao.delegate = self;
    removeDao.successMethod = @selector(removeFromAlbumSuccessCallback);
    removeDao.failMethod = @selector(removeFromAlbumFailCallback:);
    
    favDao = [[FavoriteDao alloc] init];
    favDao.delegate = self;
    favDao.successMethod = @selector(favSuccessCallback:);
    favDao.failMethod = @selector(favFailCallback:);
    
    renameDao = [[RenameDao alloc] init];
    renameDao.delegate = self;
    renameDao.successMethod = @selector(renameSuccessCallback:);
    renameDao.failMethod = @selector(renameFailCallback:);
    
    shareDao = [[ShareLinkDao alloc] init];
    shareDao.delegate = self;
    shareDao.successMethod = @selector(shareSuccessCallback:);
    shareDao.failMethod = @selector(shareFailCallback:);
    
    coverDao = [[CoverPhotoDao alloc] init];
    coverDao.delegate = self;
    coverDao.successMethod = @selector(coverSuccessCallback);
    coverDao.failMethod = @selector(coverFailCallback:);
    
    
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
    mainScroll.delegate = self;
    mainScroll.maximumZoomScale = 5.0f;
    [self.view addSubview:mainScroll];
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *imgUrlStr = [self.file.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(self.file.detail && self.file.detail.thumbLargeUrl) {
        imgUrlStr = [self.file.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    [self showLoading];
    __weak ImagePreviewController *weakSelf = self;
    [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf hideLoading];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf hideLoading];
    }];
    /*
     [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
     imgView.image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation: UIImageOrientationUp];
     } failure:nil];
     */
    [mainScroll addSubview:imgView];
    
    footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60) withAlbum:self.album];
    footer.delegate = self;
    [self.view addSubview:footer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

//- (id)initWithFile:(MetaFile *) _file {
//    return [self initWithFile:_file referencedFromAlbum:NO];
//}

//- (id)initWithFile:(MetaFile *) _file referencedFromAlbum:(BOOL) srcAlbumFlag {
//    self = [super init];
//    if (self) {
//        self.file = _file;
//        self.title = self.file.visibleName;
//        self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];
//        refFromAlbumFlag = srcAlbumFlag;
//
//        self.view.autoresizesSubviews = YES;
//        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//
//        deleteDao = [[DeleteDao alloc] init];
//        deleteDao.delegate = self;
//        deleteDao.successMethod = @selector(deleteSuccessCallback);
//        deleteDao.failMethod = @selector(deleteFailCallback:);
//
//        removeFromAlbumDao = [[AlbumRemovePhotosDao alloc] init];
//        removeFromAlbumDao.delegate = self;
//        removeFromAlbumDao.successMethod = @selector(removeFromAlbumSuccessCallback);
//        removeFromAlbumDao.failMethod = @selector(removeFromAlbumFailCallback:);
//
//        favDao = [[FavoriteDao alloc] init];
//        favDao.delegate = self;
//        favDao.successMethod = @selector(favSuccessCallback:);
//        favDao.failMethod = @selector(favFailCallback:);
//
//        renameDao = [[RenameDao alloc] init];
//        renameDao.delegate = self;
//        renameDao.successMethod = @selector(renameSuccessCallback:);
//        renameDao.failMethod = @selector(renameFailCallback:);
//
//        shareDao = [[ShareLinkDao alloc] init];
//        shareDao.delegate = self;
//        shareDao.successMethod = @selector(shareSuccessCallback:);
//        shareDao.failMethod = @selector(shareFailCallback:);
//
//        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
//        mainScroll.delegate = self;
//        mainScroll.maximumZoomScale = 5.0f;
//        [self.view addSubview:mainScroll];
//
//        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height)];
//        imgView.contentMode = UIViewContentModeScaleAspectFit;
//        NSString *imgUrlStr = [self.file.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        if(self.file.detail && self.file.detail.thumbLargeUrl) {
//            imgUrlStr = [self.file.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//        [self showLoading];
//        __weak ImagePreviewController *weakSelf = self;
//        [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            [weakSelf hideLoading];
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            [weakSelf hideLoading];
//        }];
//        /*
//        [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            imgView.image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation: UIImageOrientationUp];
//        } failure:nil];
//         */
//        [mainScroll addSubview:imgView];
//
//        footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
//        footer.delegate = self;
//        [self.view addSubview:footer];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
//
//    }
//    return self;
//}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset {
    return [self initWithFiles:_files withImage:_file withListOffset:offset printEnabled:YES];
}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag {
    return [self initWithFiles:_files withImage:_file withListOffset:offset printEnabled:printEnabledFlag pagingEnabled:YES];
}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag pagingEnabled:(BOOL) pagingEnabled {
    self = [super init];
    if (self) {
        self.files = [_files mutableCopy];
        self.file = _file;
        cursor = [self findCursorValue];
        listOffSet = offset;
        pagingEnabledFlag = pagingEnabled;
        self.title = self.file.visibleName;
        self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];
        
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        favDao = [[FavoriteDao alloc] init];
        favDao.delegate = self;
        favDao.successMethod = @selector(favSuccessCallback:);
        favDao.failMethod = @selector(favFailCallback:);
        
        renameDao = [[RenameDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);
        
        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
        mainScroll.delegate = self;
        mainScroll.maximumZoomScale = 5.0f;
        [self.view addSubview:mainScroll];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *imgUrlStr = [self.file.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if(self.file.detail && self.file.detail.thumbLargeUrl) {
            imgUrlStr = [self.file.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [self showLoading];
        __weak ImagePreviewController *weakSelf = self;
        [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [weakSelf mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
            [weakSelf hideLoading];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [weakSelf hideLoading];
        }];
        /*
         [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         imgView.image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation: UIImageOrientationUp];
         } failure:nil];
         */
        [mainScroll addSubview:imgView];
        
        //
        footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)withPrintEnabled:printEnabledFlag withAlbum:self.album];
        footer.delegate = self;
        [self.view addSubview:footer];
        
        //
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        self.navigationItem.leftBarButtonItem = backButton;
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        
        NSLog(@"init self view height -> %f", self.view.frame.size.height);
        
        /* UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
         swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
         [self.view addGestureRecognizer:swipeleft];
         
         UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
         swiperight.direction=UISwipeGestureRecognizerDirectionRight;
         [self.view addGestureRecognizer:swiperight]; */
        [self addSwipeGestures];
        
    }
    return self;
}

-(void) addSwipeGestures {
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
}

#pragma mark gesture recognizers methods

- (void) swipeLeft:(UISwipeGestureRecognizer*) gestureRecognizer  {
    if (cursor == [self.files count]) {
        return;
    }
    else{
        [self seekPhotoInFiles:YES];
        [self loadImageView:self.file];
    }
    
}

- (void) swipeRight :(UISwipeGestureRecognizer *) gestureRecognizer {
    if (cursor == 0) {
        return;
    }
    else{
        [self seekPhotoInFiles:NO];
        [self loadImageView:self.file];
    }
}

#pragma mark photo swipe actions

- (void) loadImageView:(MetaFile *) image {
    NSString *imgUrlStr = [image.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(image.detail && image.detail.thumbLargeUrl) {
        imgUrlStr = [image.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    [self showLoading];
    __weak ImagePreviewController *weakSelf = self;
    [imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
        [weakSelf hideLoading];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf hideLoading];
    }];
    
    self.title = self.file.name;
}

- (int) findCursorValue {
    
    MetaFile *tempFile = [MetaFile alloc];
    for (int i = 0; i<[self.files count]; i++) {
        if([[self.files objectAtIndex:i] isKindOfClass:[MetaFile class]]) {
            tempFile = [self.files objectAtIndex:i];
            if ([tempFile.uuid isEqualToString:self.file.uuid]) {
                return i;
            }
        }
    }
    return 0;
}

- (BOOL) checkFileIsPhoto:(MetaFile *) isPhoto {
    if (isPhoto.contentType == ContentTypePhoto) {
        return YES;
    }
    else
        return NO;
}

- (void) seekPhotoInFiles:(BOOL) isLeftSwipe {
    if (!isLeftSwipe) {
        if (cursor == 0) {
            return;
        }else {
            cursor--;
            MetaFile *tempFile = [self.files objectAtIndex:cursor];
            if ([self checkFileIsPhoto:tempFile]) {
                self.file = tempFile;
            }
            else {
                [self seekPhotoInFiles:NO];
            }
        }
    }
    else {
        
        if (cursor == [self.files count]-1) {
            if(pagingEnabledFlag) {
                [self dynamicallyLoadNextPage];
                [self loadImageView:self.file];
            }
        } else{
            cursor++;
            MetaFile *tempFile = [self.files objectAtIndex:cursor];
            if ([self checkFileIsPhoto:tempFile]) {
                self.file = tempFile;
            }
            else {
                [self seekPhotoInFiles:YES];
            }
            
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffSet ++;
    [elasticSearchDao requestPhotosAndVideosForPage:listOffSet andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) moreFiles {
    [self hideLoading];
    [self.files addObjectsFromArray:moreFiles];
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

// MARK: UIScrollViewDelegate Functions
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    float yOffset = MAX(0, (mainScroll.frame.size.height - imgView.frame.size.height) / 2);
    float xOffset = MAX(0, (mainScroll.frame.size.width - imgView.frame.size.width) / 2);
    
    imgView.frame = CGRectMake(xOffset, yOffset, imgView.frame.size.width, imgView.frame.size.height);
}

- (void) fileDetailFooterDidTriggerDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmDeleteDidConfirm];
    } else {
        ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
        confirmDelete.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) fileDetailFooterDidTriggerRemoveFromAlbum {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmRemoveDidConfirm];
    } else {
        ConfirmRemoveModalController *confirmRemove = [[ConfirmRemoveModalController alloc] init];
        confirmRemove.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmRemove];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) fileDetailFooterDidTriggerShare {
    [self triggerShareForFiles:@[self.file.uuid]];
}

- (void) fileDetailFooterDidTriggerDownload {
    [self moreMenuDidSelectDownloadImage];
}

- (void) fileDetailFooterDidTriggerPrint {
    NSArray *tempArr = [NSArray arrayWithObject:file];
    PrintWebViewController *printController = [[PrintWebViewController alloc] initWithUrl:@"http://akillidepo.cellograf.com/" withFileList:tempArr];
    printNav = [[MyNavigationController alloc] initWithRootViewController:printController];
    
    [self presentViewController:printNav animated:YES completion:nil];
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

- (void) moreClicked {
    NSArray* list = @[[NSNumber numberWithInt:MoreMenuTypeImageDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeDelete]] ;
    if (self.album) {
        list = @[[NSNumber numberWithInt:MoreMenuTypeImageDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeRemoveFromAlbum], [NSNumber numberWithInt:MoreMenuTypeSetCoverPhoto]] ;
    }
    [self presentMoreMenuWithList:list withFileFolder:self.file];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [delegate previewedImageWasDeleted:self.file];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) removeFromAlbumSuccessCallback {
    [self proceedSuccessForProgressView];
    [delegate previewedImageWasDeleted:self.file];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) removeFromAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    [self dismissViewControllerAnimated:YES completion:nil];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    self.file.detail.favoriteFlag = [favFlag boolValue];
    [self proceedSuccessForProgressView];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(MetaFile *) updatedFileRef {
    [self proceedSuccessForProgressView];
    self.file.name = updatedFileRef.name;
    self.file.visibleName = updatedFileRef.name;
    self.file.lastModified = updatedFileRef.lastModified;
    self.title = self.file.visibleName;
}

- (void) renameFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) coverSuccessCallback {
    [self proceedSuccessForProgressView];
    self.album.cover.detail.thumbLargeUrl = self.file.detail.thumbLargeUrl;
    [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_COVER_PHOTO_SET_NOTIFICATION object:nil];
}

- (void) coverFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) fileDetailShouldRename:(NSString *)newNameVal {
    [renameDao requestRenameForFile:self.file.uuid withNewName:newNameVal];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RenameFileProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RenameFileSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RenameFileFailMessage", @"")];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectImageDetail {
    [MoreMenuView presentFileDetailForFile:file fromController:self.nav delegateOwner:self];
}

- (void) moreMenuDidSelectDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmDeleteDidConfirm];
    } else {
        ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
        confirmDelete.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) moreMenuDidSelectRemoveFromAlbum {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmRemoveDidConfirm];
    } else {
        ConfirmRemoveModalController *confirmRemove = [[ConfirmRemoveModalController alloc] init];
        confirmRemove.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmRemove];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}

- (void) moreMenuDidSelectFav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) moreMenuDidSelectUnfav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) moreMenuDidSelectShare {
    [self triggerShareForFiles:@[self.file.uuid]];
}

- (void) moreMenuDidSelectDownloadImage {
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DownloadImageProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DownloadImageSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DownloadImageFailMessage", @"")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:self.file.tempDownloadUrl] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                });
            }
        }];
    });
}

- (void) moreMenuDidSelectSetCoverPhoto {
    [coverDao requestSetCoverPhoto:self.album.uuid coverPhoto:self.file.uuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"SetCoverProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"SetCoverSuccessMessage", @"") andFailMessage:NSLocalizedString(@"SetCoverFailMessage", @"")];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    if(!error) {
        [self proceedSuccessForProgressView];
    } else {
        if([error.domain isEqualToString:@"ALAssetsLibraryErrorDomain"]) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
        }
        [self proceedFailureForProgressView];
    }
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}


- (void) confirmDeleteDidConfirm {
    if(self.file.addedAlbumUuids != nil && [self.file.addedAlbumUuids count] > 0 && !self.album) {
        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
        confirm.delegate = self;
        [APPDELEGATE showCustomConfirm:confirm];
    } else {
        [deleteDao requestDeleteFiles:@[self.file.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    }
}

- (void) confirmRemoveDidCancel {
}


- (void) confirmRemoveDidConfirm {
    [removeDao requestRemovePhotos:@[self.file.uuid] fromAlbum:self.album.uuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RemoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RemoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RemoveFailMessage", @"")];
}

//- (void) confirmDeleteDidConfirm {
//    if(self.file.addedAlbumUuids != nil && [self.file.addedAlbumUuids count] > 0 && !refFromAlbumFlag) {
//        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
//        confirm.delegate = self;
//        [APPDELEGATE showCustomConfirm:confirm];
//    } else {
//        [deleteDao requestDeleteFiles:@[self.file.uuid]];
//        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
//    }
//}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    
    // update ui
    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ImagePreviewController viewDidLoad");
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
    
    // TODO ?
    //    if(![AppUtil readDoNotShowAgainFlagForKey:TUTORIAL_DETAIL_KEY] && !APPDELEGATE.session.photoDetailTipShown) {
    //        UIWindow *window = APPDELEGATE.window;
    //        TutorialView *tutorialView = [[TutorialView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height) withBgImageName:@"img_baski_2.jpg" withTitle:@"" withKey:TUTORIAL_DETAIL_KEY doNotShowFlag:NO];
    //        [window addSubview:tutorialView];
    //        APPDELEGATE.session.photoDetailTipShown = YES;
    //        [AppUtil writeDoNotShowAgainFlagForKey:TUTORIAL_DETAIL_KEY];
    //    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear self view height -> %f", self.view.frame.size.height);
}

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

#pragma mark ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self showLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:self.file.tempDownloadUrl] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [self hideLoading];
                NSArray *activityItems = [NSArray arrayWithObjects:image, nil];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                
                activityViewController.excludedActivityTypes = @[@"com.igones.adepo.DepoShareExtension"];
                
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

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES, image);
                               } else{
                                   completionBlock(NO, nil);
                               }
                           }];
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void)orientationChanged:(NSNotification *)notification {
    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) mirrorRotation:(UIInterfaceOrientation) orientation {
    // reset zoom when orientation changed
    mainScroll.zoomScale = 1;
    
    // update mainScroll frame
    mainScroll.frame = CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - 60);
    
    // calculate imgView frame
    CGRect tmp = CGRectMake(0, 0, mainScroll.frame.size.width, self.view.frame.size.height - 60);
    UIImage *image = imgView.image;
    
    if (image != nil) {
        // calculate aspect ratios
        float ratioImgV = mainScroll.frame.size.width / mainScroll.frame.size.height;
        float ratioImg = image.size.width / image.size.height;
        
        if (ratioImgV > ratioImg) {
            // imageView is wider
            tmp.size.width = mainScroll.frame.size.height * ratioImg;
        } else {
            // image is wider
            tmp.size.height = mainScroll.frame.size.width / ratioImg;
        }
    }
    
    // update imgView
    imgView.frame = tmp;
    
    // update footer
    footer.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    [footer updateInnerViews];
    
    // set imageview offset
    [self scrollViewDidZoom:mainScroll];
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
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    [deleteDao requestDeleteFiles:@[self.file.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) cancelRequests {
    [deleteDao cancelRequest];
    deleteDao = nil;
    
    [favDao cancelRequest];
    favDao = nil;
    
    [renameDao cancelRequest];
    renameDao = nil;
    
    [shareDao cancelRequest];
    shareDao = nil;
}

@end

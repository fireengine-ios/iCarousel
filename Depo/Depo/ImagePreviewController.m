//
//  ImagePreviewController.m
//  Depo
//
//  Created by Mahir on 10/5/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ImagePreviewController.h"
#import "Util.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "PrintWebViewController.h"
#import "AppUtil.h"
#import "TutorialView.h"
#import "ZPhotoView.h"
#import "VideoPreviewController.h"
#import "SyncUtil.h"
#import "ShareActivity.h"

#define PhotosGap 30.0f
#define FooterHeight 60.0f

@interface ImagePreviewController ()

@property (nonatomic, assign) UIInterfaceOrientation previousOrientation;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) NSInteger defaultPage;
@property (nonatomic) int fileCursor;
@property (nonatomic) UITapGestureRecognizer *singleTap;
@property (nonatomic) BOOL isNextSectionLoading;
@property (nonatomic) CustomConfirmView *confirmDialog;

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

- (id)initWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum *) _album withFiles:(NSArray *)_files isFileInsertedToBegining:(BOOL)isFileInsertedTwice {
    self = [super init];
    if (self) {
        self.files = [_files mutableCopy];
        _packageSize = 21;
        if (isFileInsertedTwice) {
            [self.files removeObjectAtIndex:0];
        }
        [self configureWithFile:_file withAlbum:_album];
    }
    return self;
}

-(void)configureWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum *) _album {
    self.file = _file;
    self.album = _album;
    
    cursor = [self findCursorValue];
    [self configureCommonDaos];
    
    removeDao = [[AlbumRemovePhotosDao alloc] init];
    removeDao.delegate = self;
    removeDao.successMethod = @selector(removeFromAlbumSuccessCallback);
    removeDao.failMethod = @selector(removeFromAlbumFailCallback:);
    
    coverDao = [[CoverPhotoDao alloc] init];
    coverDao.delegate = self;
    coverDao.successMethod = @selector(coverSuccessCallback);
    coverDao.failMethod = @selector(coverFailCallback:);
    
    [self drawUI:true];
}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset isFileInsertedToBegining:(BOOL)isFileInsertedTwice {
    return [self initWithFiles:_files withImage:_file withListOffset:offset printEnabled:YES isFileInsertedToBegining:isFileInsertedTwice];
}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag isFileInsertedToBegining:(BOOL)isFileInsertedTwice {
    return [self initWithFiles:_files withImage:_file withListOffset:offset printEnabled:printEnabledFlag pagingEnabled:NO isFileInsertedToBegining:isFileInsertedTwice];
}

- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag pagingEnabled:(BOOL) pagingEnabled isFileInsertedToBegining:(BOOL)isFileInsertedTwice {
    self = [super init];
    if (self) {
        self.files = [_files mutableCopy];
        pagingEnabledFlag = pagingEnabled;
        listOffSet = offset;
        _packageSize = 21;
        
        if (isFileInsertedTwice) {
            [self.files removeObjectAtIndex:0];
        }
        self.file = _file;
        cursor = [self findCursorValue];
        
        [self configureCommonDaos];
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);
        
        [self drawUI:printEnabledFlag];
    }
    return self;
}

- (void) configureCommonDaos {
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
}

- (void) drawUI:(BOOL) printEnabledFlag {
    self.title = self.file.visibleName;
    self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    _isFullScreen = false;
    
    // main scroll
    CGRect mainScrollFrame = CGRectZero;
    mainScrollFrame.origin.x = - (PhotosGap / 2.0f);
    mainScrollFrame.size.width = self.view.frame.size.width + PhotosGap;
    mainScrollFrame.size.height = self.view.frame.size.height - 60;
    
    mainScroll = [[UIScrollView alloc] initWithFrame:mainScrollFrame];
    [mainScroll setContentSize:CGSizeMake((self.view.frame.size.width + PhotosGap) * 3, self.view.frame.size.height)];
    mainScroll.pagingEnabled = true;
    mainScroll.delegate = self;
    mainScroll.showsVerticalScrollIndicator = false;
    mainScroll.showsHorizontalScrollIndicator = false;
    [self.view addSubview:mainScroll];
    
    // add gestures
    [self addGesturesWithSwipeEnabled:false];
    
    _fileCursor = [self findCursorValue];
    
    // photos
    CGRect photoFrame = self.view.frame;
    photoFrame.size.height = photoFrame.size.height - 60;
    
    int cur = [self findCursorValue];
    
    // debug log
//    NSLog(@"file cursor %i", _fileCursor);
//    NSLog(@"cfile -> %@", self.file.uuid);
//    for (MetaFile *f in self.files) {
//        NSLog(@"%@", f.uuid);
//    }
    
//    ZPhotoView *zp1, *zp2, *zp3;
    _pages = [NSMutableArray new];
    
    // previous photo
    if ((cur - 1) > -1) {
        MetaFile *mfile = self.files[cur - 1];
        UIView *view = [self createMetaFileViewWithFile:mfile viewFrame:photoFrame];
        
        if (view) {
            [mainScroll addSubview:view];
            [_pages addObject:view];
            _defaultPage = 1;
        }
    } else {
        _defaultPage = 0;
    }
    
    // selected photo
    if (self.file) {
        MetaFile *mfile = self.file;
        UIView *view = [self createMetaFileViewWithFile:mfile viewFrame:photoFrame];
        
        if (view) {
            [mainScroll addSubview:view];
            [_pages addObject:view];
        }
    }
    
    // next photo
    if ((cur + 1) < self.files.count) {
        MetaFile *mfile = self.files[cur + 1];
        UIView *zp = [self createMetaFileViewWithFile:mfile viewFrame:photoFrame];
        
        if (zp) {
            [mainScroll addSubview:zp];
            [_pages addObject:zp];
        }
    }
    
    // footer
    footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60) withPrintEnabled:printEnabledFlag withAlbum:self.album];
    footer.delegate = self;
    [self.view addSubview:footer];
    
    // add back button
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (UIView*) createMetaFileViewWithFile:(MetaFile*)mfile viewFrame:(CGRect)frame {
    if ([self checkFileIsPhoto:mfile]) {
        ZPhotoView *zp = [[ZPhotoView alloc] initWithFrame:frame
                                                 imageFile:mfile
                                             isZoomEnabled:[self checkFileIsPhoto:mfile]];
        [_singleTap requireGestureRecognizerToFail:[zp getDoubleTapGestureRecognizer]];
        return zp;
        
    } else if (mfile.contentType == ContentTypeVideo) {
        VideoView *vid = [[VideoView alloc] initWithFrame:frame withFile:mfile];
        vid.delegate = self;
        return vid;
    } else {
        return nil;
    }
}

- (void) resizeMainScrollWithGap:(CGFloat)gap viewFrame:(CGRect)frame {
    // main scroll
    CGRect mainScrollFrame = CGRectMake(-(gap / 2.0f), frame.origin.y, frame.size.width + gap, frame.size.height);
    mainScroll.frame = mainScrollFrame;
    [mainScroll setContentSize:CGSizeMake((frame.size.width + gap) * _pages.count, frame.size.height)];
    [mainScroll setContentOffset:CGPointMake((frame.size.width + 30) * _defaultPage, 0)];
    
    // resize photos
    CGRect photoFrame = CGRectMake(gap / 2.0f, 0, frame.size.width, frame.size.height);
    for (UIView *view in _pages) {
        view.frame = photoFrame;
        if ([view isKindOfClass:[ZPhotoView class]]) {
            [(ZPhotoView*)view resizeScrollView];
        } else if ([view isKindOfClass:[VideoView class]]) {
            [(VideoView*)view resizeVideoView];
        }
        
        photoFrame.origin.x = photoFrame.origin.x + frame.size.width + 30.0f;
    }
}

- (void) resizeFooterWithIsVisible:(BOOL)isVisible {
    // update footer
    CGFloat yIndex;
    if (isVisible) {
        yIndex = FooterHeight;
    } else {
        yIndex = 0;
    }
    
    footer.frame = CGRectMake(0, self.view.frame.size.height - yIndex, self.view.frame.size.width, FooterHeight);
    [footer updateInnerViews];
    
    if (self.processView) {
        // update process view
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [self.view bringSubviewToFront:self.processView];
    }

}

- (void) addGesturesWithSwipeEnabled:(BOOL)swipeEnabled {
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    _singleTap.numberOfTapsRequired = 1;
    
    [mainScroll addGestureRecognizer:_singleTap];
}

- (CGRect) calculateZoomRect:(UIGestureRecognizer *)gesture zoomScale:(CGFloat)scale {
    CGPoint point = [gesture locationInView: imgView];
    
    CGSize size = CGSizeMake(mainScroll.frame.size.width / scale, mainScroll.frame.size.height / scale);
    CGPoint origin = CGPointMake(point.x - size.width / 2, point.y - size.height / 2);
    
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

#pragma mark gesture recognizers methods

- (void) onSingleTap:(UIGestureRecognizer *)gesture {
    // note: video fullscreen status also controlled with controlVisibilityChanged
    
    if (_isFullScreen) {
        [self exitFullScreen];
    } else {
        [self enterFullScreen];
    }
}

#pragma mark - UIScrollViewDelegate Functions

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = lround(mainScroll.contentOffset.x / mainScroll.frame.size.width);
    if (page < 0 || page > 2) {
        return;
    }
    
    // page changed
    if (_defaultPage != page) {
        
        UIView *view = _pages[_defaultPage];
        if ([view isKindOfClass:[VideoView class]]) {
            [(VideoView*)view stopVideoAndReCreateView];
        }
        
        NSString *direction = @"";
        // to left
        if (_defaultPage > page) {
            direction = @"left";
            _fileCursor--;
            [self addPageToLeft];
            
        // to right
        } else {
            direction = @"right";
            _fileCursor++;
            [self addPageToRight];
            if (pagingEnabledFlag && (_fileCursor +2) >= self.files.count && !_isNextSectionLoading) {
                _isNextSectionLoading = true;
                [self dynamicallyLoadNextPage];
            }
        }
        
        // log
        NSString *log = [NSString stringWithFormat:@"ImagePreviewController: Page Changed=%@, Cursor=%i, File Count=%lu", direction, _fileCursor, self.files.count];
        IGLog(log);
        
        // set page
        self.file = self.files[_fileCursor];
        self.title = self.file.visibleName;
        
        [self resizeMainScroll];
    }
}

- (void)resizeMainScroll {
    // resize
    CGFloat topOffset = 0;
    if (!_isFullScreen) {
        CGFloat navbarheight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusbarheight = 0.0f;
        if (UIInterfaceOrientationIsPortrait(self.previousOrientation)) {
            statusbarheight = 20.0f;
        }
        topOffset = navbarheight + statusbarheight;
    }
    
    CGRect frame = CGRectMake(0, -1 * topOffset, self.view.frame.size.width, self.view.frame.size.height + topOffset);
    [self resizeMainScrollWithGap:PhotosGap viewFrame:frame];
    if (!_isFullScreen) {
        [UIView animateWithDuration:0.3f animations:^{
            [self resizeFooterWithIsVisible:(self.file.contentType == ContentTypePhoto)];
        }];
    }
}

#pragma mark - Photo Infinite Scroll Functions

- (void)addPageToLeft {
    // eger ilk sayfa ise
    if (_fileCursor == 0) {
        _defaultPage = 0;
    }
    if (_pages.count == 3) {
        // delete first page
        [((ZPhotoView*)_pages[_pages.count -1]) removeFromSuperview];
        [_pages removeObjectAtIndex:_pages.count -1];
    }
    
    // seek file
    int cur = _fileCursor - 1;
//    NSLog(@"l->%i", cur);
    if (cur < 0 || self.files.count <= cur) {
        return;
    }
    
    // prepare photo
    MetaFile *mfile = self.files[cur];
    CGRect photoFrame = self.view.frame;
    photoFrame.size.height = photoFrame.size.height - FooterHeight;
    
    UIView *zp = [self createMetaFileViewWithFile:mfile viewFrame:photoFrame];
    if (zp == nil) {
        return;
    }
    
    // add to end
    [mainScroll addSubview:zp];
    [_pages insertObject:zp atIndex:0];
}

- (void)addPageToRight {
    // delete first page
    if (_pages.count == 2) {
        _defaultPage = 1;
    } else if (_pages.count == 3) {
        [((ZPhotoView*)_pages[0]) removeFromSuperview];
        [_pages removeObjectAtIndex:0];
    }
    
    // seek file
    int cur = _fileCursor + 1;
//    NSLog(@"r->%i", cur);
    if (cur < 0 || self.files.count <= cur) {
        return;
    }
    
    // prepare photo
    MetaFile *mfile = self.files[cur];
    CGRect photoFrame = self.view.frame;
    photoFrame.size.height = photoFrame.size.height - FooterHeight;
    
    UIView *zp = [self createMetaFileViewWithFile:mfile viewFrame:photoFrame];
    if (zp == nil) {
        return;
    }
    
    // add to end
    [mainScroll addSubview:zp];
    [_pages addObject:zp];
}

// load next section
- (void) dynamicallyLoadNextPage {
    listOffSet ++;
    IGLog(@"ImagePreviewController dynamicallyLoadNextPage: Started");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    [elasticSearchDao requestPhotosAndVideosForPage:listOffSet andSize:_packageSize andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) moreFiles {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    
    if (moreFiles.count > 0) {
        MetaFile *lastFile = self.files[self.files.count -1];
        
        [self.files addObjectsFromArray:moreFiles];
        
        // add page if mainscroll is in the end
        if (self.file.uuid == lastFile.uuid) {
            [self addPageToRight];
            [self resizeMainScroll];
        }
    }
    
    _isNextSectionLoading = false;
    NSString *log = [NSString stringWithFormat:@"ImagePreviewController dynamicallyLoadNextPage: Succeeded, %lu more file loaded, total=%lu", moreFiles.count, self.files.count];
    IGLog(log);
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    [self showErrorAlertWithMessage:errorMessage];
    _isNextSectionLoading = false;
    IGLog(@"ImagePreviewController dynamicallyLoadNextPage: Failed");
}

- (void)enterFullScreen {
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self.navigationController setNavigationBarHidden:true animated:true];
        [[UIApplication sharedApplication] setStatusBarHidden:true];
        
        // update process view
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        // update footer
        footer.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60);
        [footer updateInnerViews];
        
        CGRect f = mainScroll.frame;
        f.origin.y = 0;
        mainScroll.frame = f;
        
        _isFullScreen = true;
    }];
}

- (void)exitFullScreen {
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self.navigationController setNavigationBarHidden:false animated:true];
        
        if (UIInterfaceOrientationIsPortrait(self.previousOrientation)) {
            [[UIApplication sharedApplication] setStatusBarHidden:false];
        }
        
        // update process view
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        // update footer
        if (self.file.contentType == ContentTypePhoto) {
            footer.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
            [footer updateInnerViews];
        }
        
        CGFloat navbarheight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusbarheight = 0.0f;
        if (UIInterfaceOrientationIsPortrait(self.previousOrientation)) {
            statusbarheight = 20.0f;
        }
        
        CGRect f = mainScroll.frame;
        f.origin.y = -1 * (navbarheight + statusbarheight);
        mainScroll.frame = f;
        
        _isFullScreen = false;
    }];
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

#pragma mark - VideoViewDelegate

- (void) videoDidStartPlay {
    NSLog(@"customPlayerDidStartPlay");
}

- (void) videoDidPause {
    NSLog(@"customPlayerDidPause");
}

- (void) controlVisibilityChanged:(BOOL)visibility {
    NSLog(@"controlVisibilityChanged %@", visibility?@"YES":@"NO");
    
    if (visibility) {
        [self exitFullScreen];
    } else {
        [self enterFullScreen];
    }
}

#pragma mark - Menu Actions

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
    NSArray* list = @[];
    if (self.file.contentType == ContentTypePhoto) {
        list = @[[NSNumber numberWithInt:MoreMenuTypeImageDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeDelete]] ;
        if (self.album) {
            list = @[[NSNumber numberWithInt:MoreMenuTypeImageDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeRemoveFromAlbum], [NSNumber numberWithInt:MoreMenuTypeSetCoverPhoto]] ;
        }
    } else if (self.file.contentType == ContentTypeVideo) {
        list = @[[NSNumber numberWithInt:MoreMenuTypeVideoDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeDelete]];
        if (self.album) {
            list = @[[NSNumber numberWithInt:MoreMenuTypeVideoDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeRemoveFromAlbum], [NSNumber numberWithInt:MoreMenuTypeSetCoverPhoto]] ;
        }
    }
    
    [self presentMoreMenuWithList:list withFileFolder:self.file];
}

#pragma mark - DAO Callback Methods
- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    // previewedVideoWasDeleted delegate metdod does the same
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
    [self.files removeObjectAtIndex:_fileCursor];
    [(UIView*)_pages[_defaultPage] removeFromSuperview];
    [_pages removeObjectAtIndex:_defaultPage];
    [self addPageToRight];
    
    if (self.files.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [APPDELEGATE.base checkAndShowAddButton];
        return;
    }
    
    // set page
    self.file = self.files[_fileCursor];
    self.title = self.file.visibleName;
    
    // resize
    CGFloat topOffset = 0;
    if (!_isFullScreen) {
        CGFloat navbarheight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusbarheight = 0.0f;
        if (UIInterfaceOrientationIsPortrait(self.previousOrientation)) {
            statusbarheight = 20.0f;
        }
        topOffset = navbarheight + statusbarheight;
    }
    
    CGRect frame = CGRectMake(0, -1 * topOffset, self.view.frame.size.width, self.view.frame.size.height + topOffset);
    [self resizeMainScrollWithGap:PhotosGap viewFrame:frame];
    if (!_isFullScreen) {
        [UIView animateWithDuration:0.3f animations:^{
            [self resizeFooterWithIsVisible:(self.file.contentType == ContentTypePhoto)];
        }];
    }
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
    self.files[_fileCursor] = self.file;
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

#pragma mark - MoreMenuDelegate

- (void) moreMenuDidSelectImageDetail {
    [MoreMenuView presentFileDetailForFile:file fromController:self.nav delegateOwner:self];
}

- (void) moreMenuDidSelectVideoDetail {
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
    if (self.file.contentType == ContentTypePhoto) {
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DownloadImageProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DownloadImageSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DownloadImageFailMessage", @"")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self downloadImageWithURL:[NSURL URLWithString:self.file.tempDownloadUrl]
                       completionBlock:
             ^(BOOL succeeded, UIImage *image, NSData *imageData) {
                 if (succeeded) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                         [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                             NSLog(@"%@", assetURL);
                             NSString *localHash = [SyncUtil md5StringOfString:[assetURL absoluteString]];
                             [SyncUtil cacheSyncHashLocally:localHash];
                             [SyncUtil increaseAutoSyncIndex];
                         }];
                         [self image:image didFinishSavingWithError:nil contextInfo:nil];
                     });
                 }
             }];
        });
    } else if (self.file.contentType == ContentTypeVideo) {
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DownloadVideoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DownloadVideoSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
        
        NSURL *sourceURL = [NSURL URLWithString:self.file.tempDownloadUrl];
        
        NSString *contentType = @"mp4";
        NSArray *contentTypeComponents = [self.file.name componentsSeparatedByString:@"."];
        if(contentTypeComponents != nil && [contentTypeComponents count] > 0) {
            contentType = [contentTypeComponents objectAtIndex:[contentTypeComponents count]-1];
        }
        
        NSURLSessionTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:sourceURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (error) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
            }
            else {
                NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [sourceURL lastPathComponent], contentType]];
                if (location) {
                    if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil]) {
                        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempURL.path)) {
                            UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self proceedFailureForProgressView];
                            });
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self proceedFailureForProgressView];
                        });
                    }
                }
                else {
                    [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
                }
            }
        }];
        [downloadTask resume];
    }
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

- (void) video:(NSString *) videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    
    @try {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    if(!error) {
        [self proceedSuccessForProgressView];
    } else {
        [self proceedFailureForProgressView];
    }
}

#pragma mark - ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}


- (void) confirmDeleteDidConfirm {
    if(self.file.addedAlbumUuids != nil && [self.file.addedAlbumUuids count] > 0 && !self.album) {
        // 0.1 sn sonra acilmasi ekran orientation degisikleri sirasinda yasanabilecek hatadan koruyor.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showDeleteConfirmDialog];
        });
    } else {
        [deleteDao requestDeleteFiles:@[self.file.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    }
}

- (void) showDeleteConfirmDialog {
    _confirmDialog = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
    _confirmDialog.delegate = self;
    [APPDELEGATE showCustomConfirm:_confirmDialog];
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

#pragma mark - UI Lifecycle

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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    // update ui
    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.processView) {
        // update process view
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [self.view bringSubviewToFront:self.processView];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    
    for (UIView* view in _pages) {
        if ([view isKindOfClass:[ZPhotoView class]]) {
            
        } else if ([view isKindOfClass:[VideoView class]]) {
            [(VideoView*)view stopVideo];
        }
    }
}

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
//    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
    
    [self downloadImageWithURL:[NSURL URLWithString:self.file.tempDownloadUrl]
               completionBlock:^(BOOL succeeded, UIImage *image, NSData *imageData) {
                   if (succeeded) {
                       [self hideLoading];
                       
                       NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:self.file.name]];
                       [imageData writeToURL:url atomically:NO];
                       
                       NSArray *activityItems = @[url];
                       
                       BOOL thisIsAnImage = self.file.contentType == ContentTypePhoto;
                       
                       NSArray *applicationActivities = nil;
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
                           activityViewController.excludedActivityTypes = @[@"com.igones.adepo.DepoShareExtension", UIActivityTypePostToFacebook];
                       }
                       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                           [self presentViewController:activityViewController animated:YES completion:nil];
                       } else {
                           UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                           [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                       }
                       
                   }
               }];
}

#pragma mark - ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self showLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:self.file.tempDownloadUrl]
                   completionBlock:^(BOOL succeeded, UIImage *image, NSData *imageData) {
            if (succeeded) {
                [self hideLoading];
                
                NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:self.file.name]];
                [imageData writeToURL:url atomically:NO];
                
                NSArray *activityItems = @[url];
                
                ShareActivity *activity = [[ShareActivity alloc] init];
                activity.sourceViewController = self;
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                                    initWithActivityItems:activityItems
                                                                    applicationActivities:@[activity]];
                [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                
                activityViewController.excludedActivityTypes = @[@"com.igones.adepo.DepoShareExtension", UIActivityTypePostToFacebook];
                
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

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSData *imageData))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       UIImage *image = [[UIImage alloc] initWithData:data];
                                       completionBlock(YES, image, data);
                                   });
                               } else{
                                   completionBlock(NO, nil, nil);
                               }
                           }];
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void)orientationChanged:(NSNotification *)notification {
    
    [UIView beginAnimations:@"" context:NULL];
    if(self.moreMenuView) {
        [super dismissMoreMenu];
        [self moreClicked];
    }
    
    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
    [UIView commitAnimations];
}

- (void) mirrorRotation:(UIInterfaceOrientation) orientation {
    // return if orientation is same
    if (orientation == self.previousOrientation) {
        return;
    }
    self.previousOrientation = orientation;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:true];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:false];
    }
    
    CGFloat navbarheight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusbarheight = 0.0f;
    if (UIInterfaceOrientationIsPortrait(self.previousOrientation)) {
        statusbarheight = 20.0f;
    }
    CGFloat topOffset = navbarheight + statusbarheight;

    CGRect frame = CGRectMake(0, -1 * topOffset, self.view.frame.size.width, self.view.frame.size.height + topOffset);
    if (_isFullScreen) {
        frame.size.height = self.view.frame.size.height;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // exit full screeen without resizing mainScroll
        [self.navigationController setNavigationBarHidden:false];
        _isFullScreen = false;
        
        // resize mainScroll
        [self resizeMainScrollWithGap:30 viewFrame:frame];
        [self resizeFooterWithIsVisible:(self.file.contentType == ContentTypePhoto)];
        
        // resize confirm dialog if exists
        if(_confirmDialog != nil) {
            [_confirmDialog removeFromSuperview];
            [self showDeleteConfirmDialog];
        }
    });
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
    _confirmDialog = nil;
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    _confirmDialog = nil;
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

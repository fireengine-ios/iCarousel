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

- (id)initWithFile:(MetaFile *) _file {
    self = [super init];
    if (self) {
        self.file = _file;
        self.title = self.file.visibleName;
        self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];

        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

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
        
        footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footer.delegate = self;
        [self.view addSubview:footer];

        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

    }
    return self;
}

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
        
        footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)withPrintEnabled:printEnabledFlag];
        footer.delegate = self;
        [self.view addSubview:footer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        
        UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
        swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeleft];
        
        UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
        swiperight.direction=UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swiperight];
        
    }
    return self;
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
        [weakSelf hideLoading];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf hideLoading];
    }];
    
    self.title = self.file.name;
}

- (int) findCursorValue{
   
    MetaFile *tempFile = [MetaFile alloc];
    int cursorFound = 0;
    for (int i = 0; i<[self.files count]; i++) {
        if([[self.files objectAtIndex:i] isKindOfClass:[MetaFile class]]) {
            tempFile = [self.files objectAtIndex:i];
            if ([tempFile.uuid isEqualToString:self.file.uuid]) {
                cursorFound = i;
            }
        }
    }
    return cursorFound;
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
    [elasticSearchDao requestPhotosForPage:listOffSet andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) moreFiles {
    [self hideLoading];
    [self.files addObjectsFromArray:moreFiles];
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imgView;
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

- (void) fileDetailFooterDidTriggerShare {
    [self triggerShareForFiles:@[self.file.uuid]];
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
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeImageDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeDelete]] withFileFolder:self.file];
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

- (void) fileDetailShouldRename:(NSString *)newNameVal {
    [renameDao requestRenameForFile:self.file.uuid withNewName:newNameVal];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RenameFileProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RenameFileSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RenameFileFailMessage", @"")];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectImageDetail {
    FileDetailModalController *fileDetail = [[FileDetailModalController alloc] initWithFile:file];
    fileDetail.delegate = self;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:fileDetail];
    [self presentViewController:modalNav animated:YES completion:nil];
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    if(!error) {
        [self proceedSuccessForProgressView];
    } else {
        [self proceedFailureForProgressView];
    }
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    [deleteDao requestDeleteFiles:@[self.file.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"191e24"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"3fb0e8"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ImagePreviewController viewDidLoad");
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;

    if(![AppUtil readDoNotShowAgainFlagForKey:TUTORIAL_DETAIL_KEY] && !APPDELEGATE.session.photoDetailTipShown) {
        UIWindow *window = APPDELEGATE.window;
        TutorialView *tutorialView = [[TutorialView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height) withBgImageName:@"img_baski_2.jpg" withTitle:@"" withKey:TUTORIAL_DETAIL_KEY];
        [window addSubview:tutorialView];
        APPDELEGATE.session.photoDetailTipShown = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;

    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
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
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        mainScroll.frame = CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - 60);
        imgView.frame = CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height);
        footer.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [footer updateInnerViews];
    } else {
        mainScroll.frame = CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - 60);
        imgView.frame = CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height);
        footer.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [footer updateInnerViews];
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
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end

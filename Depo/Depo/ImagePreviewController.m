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

@interface ImagePreviewController ()

@end

@implementation ImagePreviewController

@synthesize delegate;
@synthesize file;

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
        [imgView setImageWithURL:[NSURL URLWithString:imgUrlStr]];
        [mainScroll addSubview:imgView];
        
        footer = [[FileDetailFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footer.delegate = self;
        [self.view addSubview:footer];

        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imgView;
}

- (void) fileDetailFooterDidTriggerDelete {
    ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
    confirmDelete.delegate = self;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) fileDetailFooterDidTriggerShare {
    [self triggerShareForFiles:@[self.file.uuid]];
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
    ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
    confirmDelete.delegate = self;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
    [self presentViewController:modalNav animated:YES completion:nil];
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
    NSLog(@"At INNER moreMenuDidSelectShare");
    [self triggerShareForFiles:@[self.file.uuid]];
}

- (void) moreMenuDidSelectDownloadImage {
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DownloadImageProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DownloadImageSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DownloadImageFailMessage", @"")];
    UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
    NSLog(@"At INNER confirmDeleteDidCancel");
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
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
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
    [self hideLoading];
    NSArray *activityItems = [NSArray arrayWithObjects:linkToShare, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
//    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void)orientationChanged:(NSNotification *)notification {
    [self mirrorRotation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) mirrorRotation:(UIInterfaceOrientation) orientation {
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        mainScroll.frame = CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex);
        imgView.frame = CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height);
        footer.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        [footer updateInnerViews];
    } else {
        mainScroll.frame = CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex);
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

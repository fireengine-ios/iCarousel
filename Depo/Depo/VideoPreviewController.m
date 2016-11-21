//
//  VideoPreviewController.m
//  Depo
//
//  Created by Mahir on 10/14/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "VideoPreviewController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface VideoPreviewController ()

@end

@implementation VideoPreviewController

@synthesize delegate;
@synthesize file;
@synthesize avPlayer;
@synthesize album;

- (id)initWithFile:(MetaFile *) _file  {
    return [self initWithFile:_file withAlbum:nil];
}

- (id)initWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum*) _album {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        self.file = _file;
        self.title = self.file.visibleName;
        self.album = _album;
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        //TakingBack RemoveFromAlbum
//        removeDao = [[AlbumRemovePhotosDao alloc] init];
//        removeDao.delegate = self;
//        removeDao.successMethod = @selector(removeFromAlbumSuccessCallback);
//        removeDao.failMethod = @selector(removeFromAlbumFailCallback:);
        
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
        
        avPlayer = [[CustomAVPlayer alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex) withVideo:self.file];
        avPlayer.delegate = self;
        [self.view addSubview:avPlayer];
        avPlayer.autoresizesSubviews = YES;
        avPlayer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
    }
    return self;
}

//- (id)initWithFile:(MetaFile *) _file  {
//    return [self initWithFile:_file referencedFromAlbum:NO];
//}
//
//- (id)initWithFile:(MetaFile *) _file referencedFromAlbum:(BOOL) albumFlag {
//    self = [super init];
//    if (self) {
//        self.view.backgroundColor = [UIColor blackColor];
//        
//        self.view.autoresizesSubviews = YES;
//        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//
//        self.file = _file;
//        self.title = self.file.visibleName;
//        refFromAlbumFlag = albumFlag;
//        
//        deleteDao = [[DeleteDao alloc] init];
//        deleteDao.delegate = self;
//        deleteDao.successMethod = @selector(deleteSuccessCallback);
//        deleteDao.failMethod = @selector(deleteFailCallback:);
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
//        avPlayer = [[CustomAVPlayer alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex) withVideo:self.file];
//        avPlayer.delegate = self;
//        [self.view addSubview:avPlayer];
//        avPlayer.autoresizesSubviews = YES;
//        avPlayer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//
//    }
//    return self;
//}

- (void) moreClicked {
    NSArray* list = @[[NSNumber numberWithInt:MoreMenuTypeVideoDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeDelete]];
    //TakingBack RemoveFromAlbum
//    if (self.album) {
//        list = @[[NSNumber numberWithInt:MoreMenuTypeVideoDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDownloadImage], [NSNumber numberWithInt:MoreMenuTypeRemoveFromAlbum], [NSNumber numberWithInt:MoreMenuTypeDelete]] ;
//    }
    [self presentMoreMenuWithList:list withFileFolder:self.file];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [delegate previewedVideoWasDeleted:self.file];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) removeFromAlbumSuccessCallback {
    [self proceedSuccessForProgressView];
    [delegate previewedVideoWasDeleted:self.file];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) removeFromAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    if(avPlayer) {
        [avPlayer willDismiss];
    }
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

- (void) moreMenuDidSelectVideoDetail {
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

- (void) confirmRemoveDidCancel {
}


- (void) confirmRemoveDidConfirm {
    [removeDao requestRemovePhotos:@[self.file.uuid] fromAlbum:self.album.uuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RemoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RemoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RemoveFailMessage", @"")];
}

- (void) moreMenuDidSelectFav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) moreMenuDidSelectUnfav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) moreMenuDidSelectDownloadImage {
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
                    UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
            }
            else {
                [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
            }
        }
    }];
    [downloadTask resume];
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

- (void) moreMenuDidSelectShare {
    [self triggerShareForFiles:@[self.file.uuid]];
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [APPDELEGATE.session pauseAudioItem];

    if(avPlayer) {
        if(avPlayer.currentAsset) {
            [avPlayer.player play];
        } else {
            [avPlayer initializePlayer];
        }
    }

    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if(avPlayer) {
        [avPlayer willDisappear];
    }

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

- (void) customPlayerDidScrollInitialScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.nav setNavigationBarHidden:NO animated:YES];
}

- (void) customPlayerDidScrollFullScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.nav setNavigationBarHidden:YES animated:YES];
}

- (void) customPlayerDidStartPlay {
}

- (void) customPlayerDidPause {
}

- (void) triggerDismiss {
    if(avPlayer) {
        [avPlayer willDismiss];
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ViewPreviewController viewDidLoad");
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldAutorotate {
//    if (self.avPlayer.player.rate > 0 && !self.avPlayer.player.error) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

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

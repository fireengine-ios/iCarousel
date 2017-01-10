//
//  RevisitedGroupedPhotosController.m
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedGroupedPhotosController.h"
#import "UploadingImagePreviewController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "MapUtil.h"
#import "SelectiblePhotoListModalController.h"
#import "Story.h"
#import "MPush.h"
#import "PrintWebViewController.h"
#import "AppUtil.h"
#import "TutorialView.h"
#import "MsisdnEntryController.h"
#import "EmailEntryController.h"
#import "ReachabilityManager.h"

#import "AppRater.h"

@interface RevisitedGroupedPhotosController () {
    MyNavigationController *printNav;
}
@end

@implementation RevisitedGroupedPhotosController

@synthesize segmentView;
@synthesize groupView;
@synthesize albumView;
@synthesize previousButtonRef;
@synthesize moreButton;
@synthesize usageDao;
@synthesize accountDao;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        usageDao = [[UsageInfoDao alloc] init];
        usageDao.delegate = self;
        usageDao.successMethod = @selector(usageSuccessCallback:);
        usageDao.failMethod = @selector(usageFailCallback:);

        accountDao = [[AccountDao alloc] init];
        accountDao.delegate = self;
        accountDao.successMethod = @selector(accountSuccessCallback:);
        accountDao.failMethod = @selector(accountFailCallback:);

        segmentView = [[RevisitedPhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 40)];
        segmentView.delegate = self;
        [self.view addSubview:segmentView];
        
        groupView = [[RevisitedGroupedPhotoView alloc] initWithFrame:CGRectMake(0, self.topIndex + 40, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 30)];
        groupView.delegate = self;
        [self.view addSubview:groupView];
        
        albumView = [[RevisitedAlbumListView alloc] initWithFrame:CGRectMake(0, self.topIndex + 40, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 30)];
        albumView.hidden = YES;
        albumView.delegate = self;
        [self.view addSubview:albumView];
        
        [usageDao requestUsageInfo];
        [accountDao requestActiveSubscriptions];
        
        [self reloadLists];
    }
    return self;
}

- (void) reloadLists {
    [albumView pullData];
    [groupView pullData];
}

- (void) revisitedPhotoHeaderSegmentPhotoChosen {
    [groupView neutralizeSearchBar];

    groupView.hidden = NO;
    albumView.hidden = YES;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) revisitedPhotoHeaderSegmentCollectionChosen {
    groupView.hidden = YES;
    albumView.hidden = YES;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"CollTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) revisitedPhotoHeaderSegmentAlbumChosen {
    groupView.hidden = YES;
    albumView.hidden = NO;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) setToSelectionState {
    [segmentView disableNavigate];
    if(self.navigationItem.leftBarButtonItem.tag != 111) {
        previousButtonRef = self.navigationItem.leftBarButtonItem;
    }

    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    cancelItem.tag = 111;
    self.navigationItem.leftBarButtonItem = cancelItem;
//    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
}

- (void) cancelClicked {
    [segmentView enableNavigate];

    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
//    moreButton.hidden = NO;
    
    [albumView setToUnselectible];
    [groupView setToUnselectible];

    if(!footerActionMenuDidSelect) {
        [APPDELEGATE.base immediateShowAddButton];
    }
    
    footerActionMenuDidSelect = NO;
    
//    [APPDELEGATE.base immediateShowAddButton];
}

#pragma mark RevisitedAlbumListDelegate methods

- (void) revisitedAlbumListDidChangeToSelectState {
    [groupView setToSelectible];
    [self setToSelectionState];
}

- (void) revisitedAlbumListDidFinishLoading {
}

- (void) revisitedAlbumListDidFinishDeleting {
    [segmentView enableNavigate];
    
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    //    moreButton.hidden = NO;
    
    [albumView setToUnselectiblePriorToRefresh];
    [groupView setToUnselectible];
    
    [APPDELEGATE.base immediateShowAddButton];

    [albumView pullData];
}

- (void) revisitedAlbumListDidFailRetrievingList:(NSString *)errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedAlbumListDidSelectAlbum:(PhotoAlbum *)albumSelected {
    PhotoAlbumController *albumController = [[PhotoAlbumController alloc] initWithAlbum:albumSelected];
    albumController.delegate = self;
    albumController.nav = self.nav;
    [self.navigationController pushViewController:albumController animated:YES];
}

- (void) revisitedAlbumListDownloadAlbums:(NSArray *)albums {
    [APPDELEGATE.base createAlbums:albums
                        loadingMessage:NSLocalizedString(@"DownloadAlbumsProgressMessage", @"")
                        successMessage:NSLocalizedString(@"DownloadAlbumsSuccessMessage", @"")
                           failMessage:NSLocalizedString(@"DownloadAlbumFailMessage", @"")];
    footerActionMenuDidSelect = YES;
    [self cancelClicked];
}

- (void) revisitedAlbumListShareAlbums:(NSArray *)albumUUIDs {
    [shareDao requestLinkForFiles:albumUUIDs isAlbum:true];
    [self showLoading];
}

- (void) revisitedAlbumListChangeTitleTo:(NSString *)pageTitle {
    self.title = pageTitle;
}

- (void) revisitedAlbumListDidFailDeletingWithError:(NSString *)errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedAlbumListShouldShowLoading {
    [self showLoading];
}

- (void) revisitedAlbumListShouldHideLoading {
    [self hideLoading];
}

#pragma mark RevisitedGroupPhotoDelegate methods

- (void) revisitedGroupedPhotoDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList {
    if(fileSelected.contentType == ContentTypePhoto) {
        NSMutableArray *filteredPhotoList = [[NSMutableArray alloc] init];
        [filteredPhotoList addObject:fileSelected];
        
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFiles:containingList withImage:fileSelected withListOffset:0]; //TODO
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

- (void) revisitedGroupedPhotoDidFinishLoading {
}

- (void) revisitedGroupedPhotoDidFinishDeletingOrMoving {
    [segmentView enableNavigate];
    
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    //    moreButton.hidden = NO;
    
    [albumView setToUnselectiblePriorToRefresh];
    [groupView setToUnselectiblePriorToRefresh];
    
    [APPDELEGATE.base immediateShowAddButton];

    [groupView pullData];
    [albumView pullData];
}

//- (void) revisitedGroupedPhotoDidFinishMoving {
//    [self revisitedAlbumListDidFinishDeleting];
//    [segmentView enableNavigate];
//    
//    self.title = NSLocalizedString(@"PhotosTitle", @"");
//    self.navigationItem.leftBarButtonItem = previousButtonRef;
//    //    moreButton.hidden = NO;
//    
//    [albumView setToUnselectiblePriorToRefresh];
//    [groupView setToUnselectiblePriorToRefresh];
//    
//    [APPDELEGATE.base immediateShowAddButton];
//
//    [groupView pullData];
//    [albumView pullData];
//}

- (void) revisitedGroupedPhotoShouldConfirmForDeleting {
    [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
}

- (void) revisitedGroupedPhotoShowPhotoAlbums:(RevisitedGroupedPhotoView *)view {
    [MoreMenuView presentPhotoAlbumsFromController:self.nav delegateOwner:self];
}

- (void) revisitedGroupedPhoto:(RevisitedGroupedPhotoView *)view triggerShareForFiles:(NSArray *) uuidList {
    [self triggerShareForFiles:uuidList];
}

-(void)revisitedGroupedPhoto:(RevisitedGroupedPhotoView *)view downloadSelectedFiles:(NSArray *)selectedFiles {
    NSString *loadingMessage = NSLocalizedString(@"DownloadImagesProgressMessage", @"");
    NSString *successMessage = NSLocalizedString(@"DownloadImagesSuccessMessage", @"");
    NSString *failMessage = NSLocalizedString(@"DownloadImagesFailMessage", @"");
    [APPDELEGATE.base downloadFilesToCameraRoll:selectedFiles
                                 loadingMessage:loadingMessage
                                 successMessage:successMessage
                                    failMessage:failMessage];
    footerActionMenuDidSelect = YES;
    [self cancelClicked];
}

- (void) revisitedGroupedPhotoDidChangeToSelectState {
    [albumView setToSelectible];
    [self setToSelectionState];
}

- (void) revisitedGroupedPhotoShouldPrintWithFileList:(NSArray *)fileListToPrint {
    PrintWebViewController *printController = [[PrintWebViewController alloc] initWithUrl:@"http://akillidepo.cellograf.com/" withFileList:fileListToPrint];
    printNav = [[MyNavigationController alloc] initWithRootViewController:printController];
    
    [self presentViewController:printNav animated:YES completion:nil];
}

- (void) revisitedGroupedPhotoDidFailRetrievingList:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoDidFailDeletingWithError:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoDidFailMovingWithError:(NSString *)errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoShowErrorMessage:(NSString *)errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle {
    self.title = pageTitle;
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Share

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


#pragma mark PhotoAlbumDelegate methods

- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [albumView pullData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!APPDELEGATE.session.appRaterFlag) {
        // App Rater
        [AppRater sharedInstance].daysUntilPrompt = 5;
        [AppRater sharedInstance].launchesUntilPrompt = 10;
        [AppRater sharedInstance].remindMeDaysUntilPrompt = 15;
        [AppRater sharedInstance].remindMeLaunchesUntilPrompt = 10;
        // [AppRater sharedInstance].preferredLanguage = @"en";
        [[AppRater sharedInstance] appLaunched];
        
        APPDELEGATE.session.appRaterFlag = YES;
    }

    IGLog(@"RevisitedGroupedPhotosController viewDidLoad");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoesToBg) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void) appGoesToBg {
    if(groupView) {
        [groupView neutralizeSearchBar];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(!albumView.hidden) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    }
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void)didReceiveMemoryWarning {
//TODO aç    [groupView didReceiveMemoryWarning];
    [super didReceiveMemoryWarning];
    IGLog(@"RevisitedGroupedPhotoController didReceiveMemoryWarning");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
    if(groupView) {
        [groupView neutralizeSearchBar];
    }
    if(!APPDELEGATE.session.videofyTutorialCountChecked) {
        if([AppUtil readVideofyTutorialCount] == 1) {
            NSString *imageName = @"overlay_wt_en.png";
            if([[Util readLocaleCode] isEqualToString:@"tr"]) {
                imageName = @"overlay_wt_tr.png";
            }
            TutorialView *tutorialView = [[TutorialView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withBgImageName:imageName withTitle:@"" withKey:TUTORIAL_VIDEOFY_KEY doNotShowFlag:NO];
            [APPDELEGATE.window addSubview:tutorialView];
        }
        [AppUtil increaseVideofyTutorialCount];
        APPDELEGATE.session.videofyTutorialCountChecked = YES;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *) albumName {
    [albumView addNewAlbumWithName:albumName];
}

- (void) previewedImageWasDeleted:(MetaFile *) deletedFile {
    [self reloadLists];
}

- (void) previewedVideoWasDeleted:(MetaFile *) deletedFile {
    [self reloadLists];
}

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(!groupView.hidden) {
        [groupView shouldContinueDelete];
    }
}


- (void) moreClicked {
    if(!groupView.isHidden) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSelect], [NSNumber numberWithInt:MoreMenuTypeVideofy]]];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSortWithList], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
}



#pragma mark - More Menu Delegate

-(void)moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

- (void) moreMenuDidSelectSortWithList {
    if(!albumView.isHidden) {
        NSArray *list = [NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeAlphaAsc], [NSNumber numberWithInt:SortTypeAlphaDesc], [NSNumber numberWithInt:SortTypeDateAsc], [NSNumber numberWithInt:SortTypeDateDesc], nil];
        [MoreMenuView presnetSortWithList:list fromController:self.nav delegateOwner:self];
    }
}

- (void) moreMenuDidSelectVideofy {
    NSLog(@"moreMenuDidSelectVideofy called");
    CustomEntryPopupView *entryPopup = [[CustomEntryPopupView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"CreateName", @"") withButtonTitle:NSLocalizedString(@"Save", @"")];
    entryPopup.delegate = self;
    [APPDELEGATE showCustomEntryPopup:entryPopup];
}

- (void) changeToSelectedStatus {
    if(!groupView.isHidden) {
        [groupView setToSelectible];
    } else {
        [albumView setToSelectible];
    }
    [self setToSelectionState];
}

- (void) customEntryDidDismissWithValue:(NSString *)val {
    Story *rawStory = [[Story alloc] init];
    rawStory.title = val;
    SelectiblePhotoListModalController *modalController = [[SelectiblePhotoListModalController alloc] initWithStory:rawStory];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:modalController];
    [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
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
    
    [groupView pullData];
    
    [[CurioSDK shared] sendEvent:@"ImageCapture" eventValue:@"true"];
    [MPush hitTag:@"ImageCapture" withValue:@"true"];
}

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    [groupView destinationAlbumChosenWithUuid:albumUuid];
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
    [groupView pullData];
}

- (void) cancelRequests {
    [usageDao cancelRequest];
    usageDao = nil;
    
    [groupView cancelRequests];
    [albumView cancelRequests];
}

- (void) usageSuccessCallback:(Usage *) _usage {
    APPDELEGATE.session.usage = _usage;

    double percentUsageVal = 0;
    if(APPDELEGATE.session.usage.totalStorage > 0) {
        percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);
    }
    
    if(percentUsageVal >= 80) {
        if(!APPDELEGATE.session.quotaExceed80EventFlag) {
            [[CurioSDK shared] sendEvent:@"quota_exceeded_80_perc" eventValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            [MPush hitTag:@"quota_exceeded_80_perc" withValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            APPDELEGATE.session.quotaExceed80EventFlag = YES;
        }
    }
    NSString *eventValue = nil;
    if(percentUsageVal >= 100) {
        eventValue = @"quota_full";
    } else if(percentUsageVal >= 99.0) {
        eventValue = @"quota_99_percent_full";
    } else if(percentUsageVal >= 90.0) {
        eventValue = @"quota_90_percent_full";
    } else if(percentUsageVal >= 80.0) {
        eventValue = @"quota_80_percent_full";
    }
    if(eventValue) {
        [MPush hitEvent:eventValue];
    }
    if(!isnan(percentUsageVal)) {
        [MPush hitTag:@"quota_status" withValue:[NSString stringWithFormat:@"%.0f", percentUsageVal]];
    }
    
    if(APPDELEGATE.session.usage.totalStorage > 0) {
        if(APPDELEGATE.session.usage.totalStorage - APPDELEGATE.session.usage.usedStorage <= 5242880) {
            [MPush hitTag:@"quota_5_mb_left"];
        }
    }
}

- (void) usageFailCallback:(NSString *) errorMessage {
}

//- (void) accountSuccessCallback:(NSArray *) subscriptions {
//    int counter = 1;
//    for(Subscription *subsc in subscriptions) {
//        if(subsc.plan != nil && subsc.plan.displayName != nil) {
//            NSString *tagName = [NSString stringWithFormat:@"user_package_%d", counter];
//            [MPush hitTag:tagName withValue:subsc.plan.displayName];
//            counter ++;
//        }
//    }
//}

- (void) accountSuccessCallback:(NSArray *) subscriptions {
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"onKatViewFlag"]){
        if(APPDELEGATE.session.msisdnEmpty) {
            MsisdnEntryController *msisdnController = [[MsisdnEntryController alloc] init];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:msisdnController];
            [self presentViewController:modalNav animated:YES completion:nil];
            
            //        [APPDELEGATE triggerLogout];
            //        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnEmpty", @"")];
            //        return;
        }
        else if(APPDELEGATE.session.emailEmpty && !APPDELEGATE.session.emailEmptyMessageShown) {
            APPDELEGATE.session.emailEmptyMessageShown = YES;
            [[CurioSDK shared] sendEvent:@"EmailEmpty" eventValue:@"Enter"];
            [[CurioSDK shared] sendEvent:@"EmailConfirm" eventValue:@"ok"];
            [MPush hitTag:@"EmailEmpty" withValue:@"Enter"];
            [MPush hitTag:@"EmailConfirm" withValue:@"ok"];
            EmailEntryController *emailController = [[EmailEntryController alloc] init];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:emailController];
            [self presentViewController:modalNav animated:YES completion:nil];
        } else if(APPDELEGATE.session.emailNotVerified && !APPDELEGATE.session.emailNotVerifiedMessageShown) {
            APPDELEGATE.session.emailNotVerifiedMessageShown = YES;
            [self showInfoAlertWithMessage:NSLocalizedString(@"EmailNotVerified", @"")];
        } else if([subscriptions count] > 0) {
            //TODO ilk subscription'a bakiyor, bu düzeltilecek
//            currentSubscription = [subscriptions objectAtIndex:0];
//            [self flowChartAdvertising];
            
            for(Subscription *subsc in subscriptions) {
                if(subsc.plan != nil && subsc.plan.cometOfferId != nil) {
                    if(subsc.plan.cometOfferId.intValue == 581814) {
                        [MPush hitTag:@"platin_user"];
                    }
                }
            }
            
            if(APPDELEGATE.session.user.accountType == AccountTypeTurkcell) {
                BOOL hasAnyTurkcellPackage = NO;
                for(Subscription *subscription in subscriptions) {
                    if(!subscription.type || !([subscription.type isEqualToString:@"INAPP_PURCHASE_GOOGLE"] || [subscription.type isEqualToString:@"INAPP_PURCHASE_APPLE"])) {
                        hasAnyTurkcellPackage = YES;
                    }
                }
                if(!hasAnyTurkcellPackage) {
                    if(![AppUtil readDoNotShowAgainFlagForKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"]) {
                        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"PortinInfoMessage", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"];
                        confirm.delegate = self;
                        confirm.tag = 333;
                        [APPDELEGATE showCustomConfirm:confirm];
                    }
                }
            }
        }
    }
    int counter = 1;
    for(Subscription *subsc in subscriptions) {
        if(subsc.plan != nil && subsc.plan.displayName != nil) {
            NSString *tagName = [NSString stringWithFormat:@"user_package_%d", counter];
            [MPush hitTag:tagName withValue:subsc.plan.displayName];
            counter ++;
        }
    }
}

- (void) devicePhotosDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
    [groupView pullData];
}

- (void) accountFailCallback:(NSString *) errorMessage{
}

- (BOOL) checkInternet {
    if([ReachabilityManager isReachable]) {
        return YES;
    }
    else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
        return NO;
    }
}

@end

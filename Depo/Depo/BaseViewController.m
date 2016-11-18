//
//  BaseViewController.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "BaseViewController.h"
#import "MyViewController.h"
#import "HomeController.h"
#import "FileListController.h"
#import "PhotoListController.h"
#import "SettingsController.h"
#import "AppSession.h"
#import "AppDelegate.h"
#import "AppUtil.h"
#import "NewFolderModalController.h"
#import "PhotoListModalController.h"
#import "AlbumListModalController.h"
#import "MusicListModalController.h"
#import "CameraCaptureModalController.h"
#import "NewAlbumModalController.h"
#import "ConfirmDeleteModalController.h"
#import "ConfirmRemoveModalController.h"
#import "SortModalController.h"
#import "MoveListModalController.h"
#import "MusicListController.h"
#import "MapUtil.h"
#import "DocListController.h"
#import "FolderDetailModalController.h"
#import "FileDetailModalController.h"
#import "PhotoAlbumListModalController.h"
#import "AlbumDetailModalController.h"
#import "RecentActivitiesController.h"
#import "SearchModalController.h"
#import "FavouriteListController.h"
#import "MusicPreviewController.h"
#import "ContactSyncController.h"
#import "CropAndShareListController.h"
#import "PhotoListPopupController.h"
#import "FileListPopupController.h"
#import "MPush.h"
#import "CurrentMusicListModalController.h"
#import "CurrentPhotoListModalController.h"
#import "CurrentDocumentListModalController.h"
#import "SettingsHelpController.h"
#import "ReachUsController.h"
#import "TutorialView.h"
#import "GroupedPhotosAndVideosController.h"
#import "PromotionEntryController.h"
#import "DropboxExportController.h"
#import "CellographMainController.h"
#import "NewFeatureInfoController.h"
#import "NewFeatureInfoView.h"
#import "RevisitedGroupedPhotosController.h"
#import "CustomInfoWithIconView.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize scroll;
@synthesize nav;
@synthesize menuOpen;
@synthesize menu;
@synthesize baseProgress;
@synthesize transparentView;
@synthesize addButton;
@synthesize addMenu;
@synthesize shareDao;
@synthesize menuLocked;
@synthesize syncInfoView;
//@synthesize rootViewController;
@synthesize popupCheckDone;

- (id) init {
    return [self initWithRootViewController:[[RevisitedGroupedPhotosController alloc] init]];
}

- (id) initWithRootViewController:(MyViewController *) _rootViewController {
    self = [super init];
    if (self) {

        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        scroll.scrollEnabled = NO;
        [scroll setShowsHorizontalScrollIndicator:NO];
        [scroll setShowsVerticalScrollIndicator:NO];
        
        menu = [[SlidingMenu alloc] initWithFrame:CGRectMake(0, 0, kMenuOpenOriginX, self.view.frame.size.height)];
        menu.delegate = self;
        menu.closeDelegate = self;
        [scroll addSubview:menu];
        
        nav = [[MyNavigationController alloc] initWithRootViewController:_rootViewController];
        nav.view.frame = CGRectMake(kMenuOpenOriginX, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rootViewController.nav = nav;
        _rootViewController.myDelegate = self;
        [scroll addSubview:nav.view];
        
        transparentView = [[UIView alloc] initWithFrame:CGRectMake(kMenuOpenOriginX, 0, self.view.frame.size.width, self.view.frame.size.height)];
        transparentView.hidden = YES;
        [scroll addSubview:transparentView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [transparentView addGestureRecognizer:tapGestureRecognizer];

        scroll.contentSize = CGSizeMake(kMenuOpenOriginX + 320, scroll.frame.size.height);
        [self.view addSubview:scroll];
        
        baseProgress = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        baseProgress.opacity = 0.4f;
        [self.view addSubview:baseProgress];

        self.addMenu = [[FloatingAddMenu alloc] initWithFrame:CGRectMake(kMenuOpenOriginX, 0, self.view.frame.size.width, self.view.frame.size.height) withBasePoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 65)];
        addMenu.hidden = YES;
        addMenu.delegate = self;
        [scroll addSubview:addMenu];
        
        self.addButton = [[FloatingAddButton alloc] initWithFrame:CGRectMake(kMenuOpenOriginX + (self.view.frame.size.width - 70)/2, self.view.frame.size.height - 100, 70, 70)];
        addButton.hidden = YES;
        addButton.delegate = self;
        [scroll addSubview:addButton];
        
        NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(RevisitedGroupedPhotosController.class)];
        if(addTypesForController != nil) {
            [self presentAddButtonWithList:addTypesForController];
        } else {
            [self dismissAddButton];
        }

        syncInfoView = [[SyncInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 24)];
        [self.view addSubview:syncInfoView];
        [syncInfoView hide];
        
        UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(swipeLeft:)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        recognizerLeft.delegate = self;
        [self.view addGestureRecognizer:recognizerLeft];
        
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(swipeRight:)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        recognizerRight.delegate = self;
        [self.view addGestureRecognizer:recognizerRight];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncQueueChanged) name:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil];
        
    }
    return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    if([view isKindOfClass:[VolumeSliderView class]]) {
        return NO;
    }
    return YES;
}

- (void) singleTap:(UITapGestureRecognizer *) tapRecognizer {
    if (menuOpen) {
        [self showMenu];
    }
}

- (void)swipeLeft:(UISwipeGestureRecognizer*)recognizer {
    if(menuLocked) {
        return;
    }
    
    CGPoint p = [recognizer locationInView:self.view];
    
    if (menuOpen && p.x > kMenuOpenOriginX) {
        [self showMenu];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer {
    if(menuLocked) {
        return;
    }
    
    if (!menuOpen)
        [self showMenu];
}

- (void)showMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_CLOSED_NOTIFICATION object:nil];
    CGPoint newOffset = CGPointMake(menuOpen ? kMenuOpenOriginX : 0.0, 0.0);
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.scroll.contentOffset = newOffset;
                     }
                     completion:^(BOOL finished) {
                         menuOpen = !menuOpen;
                         transparentView.hidden = !menuOpen;
                         if(menuOpen) {
                             if(![AppUtil readDoNotShowAgainFlagForKey:TUTORIAL_MENU_KEY] && !APPDELEGATE.session.menuTipShown) {
                                 TutorialView *tutorialView = [[TutorialView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withBgImageName:@"img_baski_1.jpg" withTitle:@"" withKey:TUTORIAL_MENU_KEY doNotShowFlag:NO];
                                 [self.view addSubview:tutorialView];
                                 APPDELEGATE.session.menuTipShown = YES;
                                 [AppUtil writeDoNotShowAgainFlagForKey:TUTORIAL_MENU_KEY];
                             }
                         }
                     }];
}

//- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    transparentView.hidden = YES;
//    self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
//    menuOpen = NO;
//
//    if(!popupCheckDone) {
//        popupCheckDone = YES;
//
//        if(![AppUtil readLifeboxTeaserFlag]) {
//            NewFeatureInfoView *featurePresentView = [[NewFeatureInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//            [self.view addSubview:featurePresentView];
//            [AppUtil writeLifeboxTeaserFlag];
//        } else {
//            if(!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
//                
//                if(![AppUtil readPeriodicLocInfoPopupIdleFlag]) {
//                    NSDate *lastInfoShownDate = [AppUtil readLastLocInfoPopupShownTime];
//                    BOOL showNewAlert = NO;
//                    if(!lastInfoShownDate) {
//                        showNewAlert = YES;
//                    } else {
//                        NSDate *today = [NSDate date];
//                        if([today timeIntervalSinceDate:lastInfoShownDate] > 15*24*3600) {
//                            showNewAlert = YES;
//                        }
//                    }
//                    if(showNewAlert) {
//                        CustomInfoWithIconView *locInfoPopup = [[CustomInfoWithIconView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withIcon:@"icon_locationperm.png" withInfo:NSLocalizedString(@"LocInfoPopup", @"") withSubInfo:NSLocalizedString(@"LocSubInfoPeriodicMessage", @"") isCloseable:YES];
//                        [self.view addSubview:locInfoPopup];
//                        [AppUtil writeLastLocInfoPopupShownTime];
//                    }
//                }
//            }
//        }
//    }
//}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    transparentView.hidden = YES;
    self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
    menuOpen = NO;
    
    if(!popupCheckDone) {
        popupCheckDone = YES;
        
        if(![AppUtil readLifeboxTeaserFlag]) {
            NewFeatureInfoView *featurePresentView = [[NewFeatureInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [self.view addSubview:featurePresentView];
            [AppUtil writeLifeboxTeaserFlag];
        } else {
            if(!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
                NSDate *lastInfoShownDate = [AppUtil readLastLocInfoPopupShownTime];
                NSDate *today = [NSDate date];
                if([today timeIntervalSinceDate:lastInfoShownDate] > 15*24*3600) {
                    CustomInfoWithIconView *locInfoPopup = [[CustomInfoWithIconView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withIcon:@"icon_locationperm.png" withInfo:NSLocalizedString(@"LocInfoPopup", @"") withSubInfo:NSLocalizedString(@"LocSubInfoPeriodicMessage", @"") isCloseable:YES];
                    [self.view addSubview:locInfoPopup];
                    [AppUtil writeLastLocInfoPopupShownTime];
                }
            }
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    transparentView.hidden = YES;
    self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
    menuOpen = NO;
}

- (void) callCleanBeforeChange {
    id currentController = [self.nav.viewControllers objectAtIndex:[self.nav.viewControllers count]-1];
    if([currentController respondsToSelector:@selector(cancelRequests)]) {
        [currentController performSelector:@selector(cancelRequests)];
    }
}

#pragma mark SlidingMenuDelegate

- (void) didTriggerHome {
    [self callCleanBeforeChange];
    
    [MPush hitTag:@"homepage"];
    [MPush hitEvent:@"homepage"];

    HomeController *home = [[HomeController alloc] init];
    home.nav = self.nav;
    home.myDelegate = self;
    [self.nav setViewControllers:@[home] animated:NO];
}

- (void) didTriggerLogin {
}

- (void) didTriggerCropAndShare {
    [self callCleanBeforeChange];

    CropAndShareListController *cropAndShare = [[CropAndShareListController alloc] init];
    cropAndShare.nav = self.nav;
    cropAndShare.myDelegate = self;
    [self.nav setViewControllers:@[cropAndShare] animated:NO];
}

- (void) didTriggerHelp {
    [self callCleanBeforeChange];

    SettingsHelpController *help = [[SettingsHelpController alloc] init];
    help.nav = self.nav;
    help.myDelegate = self;
    [self.nav setViewControllers:@[help] animated:NO];
}

- (void) didTriggerCellograph {
    [self callCleanBeforeChange];
    
//    CellographMainController *cello = [[CellographMainController alloc] init];
//    GroupedPhotosAndVideosController *photo = [[GroupedPhotosAndVideosController alloc] init];
    RevisitedGroupedPhotosController *photo = [[RevisitedGroupedPhotosController alloc] init];
    photo.nav = self.nav;
    photo.myDelegate = self;
    [self.nav setViewControllers:@[photo] animated:NO];
}

- (void) didTriggerReachUs {
    [self callCleanBeforeChange];

    ReachUsController *reachUs = [[ReachUsController alloc] init];
    reachUs.nav = self.nav;
    reachUs.myDelegate = self;
    [self.nav setViewControllers:@[reachUs] animated:NO];
}

- (void) didTriggerLogout {
    CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"LogoutConfirmMessage", @"") withModalType:ModalTypeApprove];
    confirm.delegate = self;
    [APPDELEGATE showCustomConfirm:confirm];
}

- (void) didTriggerFavorites {
    [self callCleanBeforeChange];

    [MPush hitTag:@"favorites"];
    [MPush hitEvent:@"favorites"];

    FavouriteListController *favourites = [[FavouriteListController alloc] init];
    favourites.nav = self.nav;
    favourites.myDelegate = self;
    [self.nav setViewControllers:@[favourites] animated:NO];
}

- (void) didTriggerFiles {
    [self callCleanBeforeChange];

    [MPush hitTag:@"all_files"];
    [MPush hitEvent:@"all_files"];

    FileListController *file = [[FileListController alloc] initForFolder:nil];
    file.nav = self.nav;
    file.myDelegate = self;
    [self.nav setViewControllers:@[file] animated:NO];
}

- (void) didTriggerPhotos {
    [self callCleanBeforeChange];

    [MPush hitTag:@"photos_and_videos"];
    [MPush hitEvent:@"photos_and_videos"];

//    GroupedPhotosAndVideosController *photo = [[GroupedPhotosAndVideosController alloc] init];
    RevisitedGroupedPhotosController *photo = [[RevisitedGroupedPhotosController alloc] init];
    photo.nav = self.nav;
    photo.myDelegate = self;
    [self.nav setViewControllers:@[photo] animated:NO];
}

- (void) didTriggerMusic {
    [self callCleanBeforeChange];

    [MPush hitTag:@"music_files"];
    [MPush hitEvent:@"music_files"];

    MusicListController *music = [[MusicListController alloc] init];
    music.nav = self.nav;
    music.myDelegate = self;
    [self.nav setViewControllers:@[music] animated:NO];
}

- (void) didTriggerDocs {
    [self callCleanBeforeChange];

    [MPush hitTag:@"documents"];
    [MPush hitEvent:@"documents"];

    DocListController *doc = [[DocListController alloc] init];
    doc.nav = self.nav;
    doc.myDelegate = self;
    [self.nav setViewControllers:@[doc] animated:NO];
}

- (void) didTriggerDropbox {
    [self callCleanBeforeChange];

    DropboxExportController *controller = [[DropboxExportController alloc] init];
    controller.nav = self.nav;
    controller.myDelegate = self;
    [self.nav setViewControllers:@[controller] animated:NO];
}

- (void) didTriggerPromotions {
    [self callCleanBeforeChange];

    PromotionEntryController *controller = [[PromotionEntryController alloc] init];
    controller.nav = self.nav;
    controller.myDelegate = self;
    [self.nav setViewControllers:@[controller] animated:NO];
}

- (void) didTriggerContactSync {
    [self callCleanBeforeChange];

    ContactSyncController *contactSync = [[ContactSyncController alloc] init];
    contactSync.nav = self.nav;
    contactSync.myDelegate = self;
    [self.nav setViewControllers:@[contactSync] animated:NO];
}

- (void) didTriggerSearch {
    [self callCleanBeforeChange];

    [MPush hitTag:@"search"];
    [MPush hitEvent:@"search"];

    SearchModalController *searchController = [[SearchModalController alloc] init];
    searchController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:searchController];
    searchController.nav = modalNav;
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) didTriggerCurrentMusic {
    [self callCleanBeforeChange];

    MusicPreviewController *musicPreview = [[MusicPreviewController alloc] initForContinuingPlaylist];
    musicPreview.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:musicPreview];
    musicPreview.nav = modalNav;
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) didTriggerProfile {
    [self callCleanBeforeChange];

    [MPush hitTag:@"settings"];
    [MPush hitEvent:@"settings"];

    SettingsController *settings = [[SettingsController alloc] init];
    settings.nav = self.nav;
    settings.myDelegate = self;
    [self.nav setViewControllers:@[settings] animated:NO];
}

- (void) showBaseLoading {
    [baseProgress show:YES];
    [self.view bringSubviewToFront:baseProgress];
}

- (void) hideBaseLoading {
    [baseProgress hide:YES];
}

#pragma mark SlidingMenuCloseDelegate

- (void) shouldClose {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_CLOSED_NOTIFICATION object:nil];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
                     }
                     completion:^(BOOL finished) {
                         transparentView.hidden = YES;
                         menuOpen = NO;
                     }];
}

#pragma mark FloatingAddButtonDelegate
- (void) floatingAddButtonDidOpenMenu {
    addMenu.hidden = NO;
    [addMenu presentWithAnimation];
}

- (void) floatingAddButtonDidCloseMenu {
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
}

#pragma mark FloatingAddDelegate
- (void) floatingMenuDidTriggerAddFolder {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    NewFolderModalController *folderController = [[NewFolderModalController alloc] init];
    folderController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:folderController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddMusic {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    MusicListModalController *musicController = [[MusicListModalController alloc] init];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:musicController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddPhoto {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];

    AlbumListModalController *imgController = [[AlbumListModalController alloc] init];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:imgController];
    imgController.delegateRef = [self.nav topViewController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerCamera {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    [AccurateLocationManager sharedInstance].delegate = self;
    [[AccurateLocationManager sharedInstance] startLocationManager];
    [self showBaseLoading];
}

- (void) accurateLocationManagerPermissionDenied {
    [self hideBaseLoading];
    [self triggerCapturaScreen];
    [[AccurateLocationManager sharedInstance] stopLocationManager];
}

- (void) accurateLocationManagerDidReceiveError:(NSString *)errorMessage {
    [self hideBaseLoading];
    [self triggerCapturaScreen];
    [[AccurateLocationManager sharedInstance] stopLocationManager];
}

- (void) accurateLocationManagerDidReceiveLocation {
    [self hideBaseLoading];
    [self triggerCapturaScreen];
    [[AccurateLocationManager sharedInstance] stopLocationManager];
}

- (void) triggerCapturaScreen {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        CameraCaptureModalController *cameraController = [[CameraCaptureModalController alloc] init];
        cameraController.modalDelegate = [self.nav topViewController];
        [self presentViewController:cameraController animated:YES completion:nil];
    } else if(authStatus == AVAuthorizationStatusDenied){
        CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage: NSLocalizedString(@"CameraAccessError", @"") withModalType:ModalTypeError];
        [APPDELEGATE showCustomAlert:alert];
    } else if(authStatus == AVAuthorizationStatusRestricted){
        NSLog(@"RESTRICTED %@", mediaType);
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", mediaType);
                CameraCaptureModalController *cameraController = [[CameraCaptureModalController alloc] init];
                cameraController.modalDelegate = [self.nav topViewController];
                [self presentViewController:cameraController animated:YES completion:nil];
            } else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
    }
}

//- (void) triggerCapturaScreen {
//    CameraCaptureModalController *cameraController = [[CameraCaptureModalController alloc] init];
//    cameraController.modalDelegate = [self.nav topViewController];
//    [self presentViewController:cameraController animated:YES completion:nil];
//}

- (void) floatingMenuDidTriggerAddAlbum {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    NewAlbumModalController *folderController = [[NewAlbumModalController alloc] init];
    folderController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:folderController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddFromDepo {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];

    FileListPopupController *fileController = [[FileListPopupController alloc] init];
//    fileController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:fileController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddPhotoFromDepo {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];

    CurrentPhotoListModalController *photoController = [[CurrentPhotoListModalController alloc] init];
    photoController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:photoController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddMusicFromDepo {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    CurrentMusicListModalController *musicController = [[CurrentMusicListModalController alloc] init];
    musicController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:musicController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) floatingMenuDidTriggerAddDocumentFromDepo {
    [addButton immediateReset];
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
    
    CurrentDocumentListModalController *docController = [[CurrentDocumentListModalController alloc] init];
    docController.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:docController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) hideAddMenu {
    addMenu.hidden = YES;
}

- (void) shouldToggleMenu {
    [self showMenu];
}

- (void) shouldTriggerLoggedInPage {
    HomeController *home = [[HomeController alloc] init];
    home.nav = self.nav;
    home.myDelegate = self;
    [self.nav setViewControllers:@[home] animated:NO];
}

- (void) shouldTriggerLogin {
    [self didTriggerLogin];
}

- (void) logoutSuccessCallback {
}

- (void) logoutFailCallback:(NSString *) errorMessage {
    [self hideBaseLoading];
}

- (void) presentAddButtonWithList:(NSArray *) addTypeList {
    [self.addMenu loadButtons:addTypeList];
    self.addButton.hidden = NO;
    [scroll bringSubviewToFront:self.addButton];
}

- (void) modifyAddButtonWithList:(NSArray *) addTypeList {
    [self.addMenu loadButtons:addTypeList];
}

- (void) dismissAddButton {
    self.addButton.hidden = YES;
}

- (void) immediateShowAddButton {
    self.addButton.hidden = NO;
}

- (void) immediateHideAddButton {
    self.addButton.hidden = YES;
}

- (BOOL) isAddButtonHidden {
    return [self.addButton isHidden];
}

- (void) checkAndShowAddButton {
    UIViewController *topController = [self.nav topViewController];
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:NSStringFromClass(topController.class)];
    if(addTypesForController != nil) {
        [self immediateShowAddButton];
    }
}

- (void) showConfirmDelete {
    ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
    confirmDelete.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
    [self presentViewController:modalNav animated:YES completion:nil];
}

//TakingBack RemoveFromAlbum
//- (void) showConfirmRemove {
//    ConfirmRemoveModalController *confirmRemove = [[ConfirmRemoveModalController alloc] init];
//    confirmRemove.delegate = [self.nav topViewController];
//    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmRemove];
//    [self presentViewController:modalNav animated:YES completion:nil];
//}

- (void) showSort {
    SortModalController *sort = [[SortModalController alloc] init];
    sort.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showSortWithList:(NSArray *) sortTypeList {
    SortModalController *sort = [[SortModalController alloc] initWithList:sortTypeList];
    sort.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showSelect {
    if([[self.nav topViewController] respondsToSelector:@selector(changeToSelectedStatus)]) {
        [[self.nav topViewController] performSelector:@selector(changeToSelectedStatus)];
    }
}

- (void) showFolderDetailForFolder:(MetaFile *) folder {
    FolderDetailModalController *folderDetail = [[FolderDetailModalController alloc] initWithFolder:folder];
    folderDetail.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:folderDetail];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showFileDetailForFile:(MetaFile *) file {
    FileDetailModalController *fileDetail = [[FileDetailModalController alloc] initWithFile:file];
    fileDetail.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:fileDetail];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showAlbumDetailForAlbum:(PhotoAlbum *) album {
    AlbumDetailModalController *albumDetail = [[AlbumDetailModalController alloc] initWithAlbum:album];
    albumDetail.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:albumDetail];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showMoveFolders {
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil];
    move.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid {
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil withExludingFolder:exludingFolderUuid];
    move.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showMoveFoldersWithExludingFolder:(NSString *) exludingFolderUuid withProhibitedFolderList:(NSArray *) prohibitedList {
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil withExludingFolder:exludingFolderUuid withProhibitedFolders:prohibitedList];
    move.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showPhotoAlbums {
    PhotoAlbumListModalController *albumList = [[PhotoAlbumListModalController alloc] init];
    albumList.delegate = [self.nav topViewController];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:albumList];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) showRecentActivities {
    RecentActivitiesController *recentActivities = [[RecentActivitiesController alloc] init];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:recentActivities];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showBaseLoading];
}

#pragma mark ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self hideBaseLoading];
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
    [self hideBaseLoading];
}

- (void) triggerShareForFileObjects:(NSArray *) fileList {
    if([fileList count] == 1 && ( (MetaFile *)[fileList objectAtIndex:0]).contentType == ContentTypePhoto) {
        MetaFile *tempToShare = (MetaFile *) [fileList objectAtIndex:0];
        if (!(tempToShare.contentType == ContentTypePhoto)) {
            [shareDao requestLinkForFiles:@[tempToShare.uuid]];
        } else {
            if([tempToShare isKindOfClass:[MetaFile class]]) {
                [self showBaseLoading];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self downloadImageWithURL:[NSURL URLWithString:tempToShare.tempDownloadUrl] completionBlock:^(BOOL succeeded, UIImage *image) {
                        if (succeeded) {
                            [self hideBaseLoading];
                            NSArray *activityItems = [NSArray arrayWithObjects:image, nil];
                            
                            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                            [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
                            activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                            
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
        [self showBaseLoading];
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    if ([[self nav] respondsToSelector:@selector(shouldAutorotate)])
        return [[self nav] shouldAutorotate];
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[self nav] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self nav] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[self nav] respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
        return [[self nav] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) lockMenu {
    self.menuLocked = YES;
}

- (void) unlockMenu {
    self.menuLocked = NO;
}

- (void) showSyncInfoView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(syncInfoView.isHidden) {
            [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
            [syncInfoView show];
        }
        [self.view bringSubviewToFront:syncInfoView];
        [syncInfoView reCheckInfo];
    });
}

- (void) hideSyncInfoView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!syncInfoView.isHidden) {
            [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelNormal];
            [syncInfoView hide];
        }
    });
}

- (void) syncQueueChanged {
    int totalAutoSyncCount = [[UploadQueue sharedInstance] totalAutoSyncCount];
    int finishedAutoSyncCount = [[UploadQueue sharedInstance] finishedAutoSyncCount];
    if(finishedAutoSyncCount < totalAutoSyncCount) {
        [self showSyncInfoView];
    } else {
        [self hideSyncInfoView];
    }
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    [MPush hitTag:@"logged_out"];
    [MPush hitEvent:@"logged_out"];
    
    [APPDELEGATE triggerLogout];
}

- (void) triggerInnerSearch {
    [self callCleanBeforeChange];
    
    [MPush hitTag:@"search"];
    [MPush hitEvent:@"search"];
    
    SearchModalController *searchController = [[SearchModalController alloc] init];
    searchController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:searchController];
    searchController.nav = modalNav;
    [self presentViewController:modalNav animated:YES completion:nil];
}

@end

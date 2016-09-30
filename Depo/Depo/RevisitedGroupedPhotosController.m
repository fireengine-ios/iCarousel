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

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");

        usageDao = [[UsageInfoDao alloc] init];
        usageDao.delegate = self;
        usageDao.successMethod = @selector(usageSuccessCallback:);
        usageDao.failMethod = @selector(usageFailCallback:);

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
        
        [self reloadLists];
    }
    return self;
}

- (void) reloadLists {
    [albumView pullData];
    [groupView pullData];
}

- (void) revisitedPhotoHeaderSegmentPhotoChosen {
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
    previousButtonRef = self.navigationItem.leftBarButtonItem;

    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
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

    [APPDELEGATE.base immediateShowAddButton];
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
    [groupView setToUnselectiblePriorToRefresh];
    
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
    [self.navigationController pushViewController:albumController animated:NO];
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
        
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFiles:filteredPhotoList withImage:fileSelected withListOffset:0]; //TODO
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

- (void) revisitedGroupedPhotoDidFinishDeleting {
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

- (void) revisitedGroupedPhotoDidFinishMoving {
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

- (void) revisitedGroupedPhotoShouldConfirmForDeleting {
    [APPDELEGATE.base showConfirmDelete];
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

- (void) revisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle {
    self.title = pageTitle;
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PhotoAlbumDelegate methods

- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [albumView pullData];
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

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(!albumView.hidden) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    }
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
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

- (void) moreMenuDidSelectSortWithList {
    if(!albumView.isHidden) {
        [APPDELEGATE.base showSortWithList:[NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeAlphaAsc], [NSNumber numberWithInt:SortTypeAlphaDesc], [NSNumber numberWithInt:SortTypeDateAsc], [NSNumber numberWithInt:SortTypeDateDesc], nil]];
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
}

- (void) usageFailCallback:(NSString *) errorMessage {
}

@end

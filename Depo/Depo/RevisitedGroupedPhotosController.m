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

@interface RevisitedGroupedPhotosController ()

@end

@implementation RevisitedGroupedPhotosController

@synthesize segmentView;
@synthesize groupView;
@synthesize collView;
@synthesize albumView;
@synthesize previousButtonRef;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        segmentView = [[RevisitedPhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        segmentView.delegate = self;
        [self.view addSubview:segmentView];
        
        groupView = [[RevisitedGroupedPhotoView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        groupView.delegate = self;
        [self.view addSubview:groupView];
        
        collView = [[RevisitedCollectionView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        collView.hidden = YES;
        collView.delegate = self;
        [self.view addSubview:collView];

        albumView = [[RevisitedAlbumListView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        albumView.hidden = YES;
        albumView.delegate = self;
        [self.view addSubview:albumView];
        
        [albumView pullData];
        [collView pullData];
        [groupView pullData];
    }
    return self;
}

- (void) revisitedPhotoHeaderSegmentPhotoChosen {
    groupView.hidden = NO;
    collView.hidden = YES;
    albumView.hidden = YES;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) revisitedPhotoHeaderSegmentCollectionChosen {
    groupView.hidden = YES;
    collView.hidden = NO;
    albumView.hidden = YES;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"CollTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) revisitedPhotoHeaderSegmentAlbumChosen {
    groupView.hidden = YES;
    collView.hidden = YES;
    albumView.hidden = NO;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) setToSelectionState {
    previousButtonRef = self.navigationItem.leftBarButtonItem;

    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
//    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
}

- (void) cancelClicked {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
//    moreButton.hidden = NO;
    
    [albumView setToUnselectible];
    [collView setToUnselectible];
    [groupView setToUnselectible];

    [APPDELEGATE.base immediateShowAddButton];
}

#pragma mark RevisitedAlbumListDelegate methods

- (void) revisitedAlbumListDidChangeToSelectState {
    [collView setToSelectible];
    [groupView setToSelectible];

    [self setToSelectionState];
}

- (void) revisitedAlbumListDidFinishLoading {
}

- (void) revisitedAlbumListDidFailRetrievingList:(NSString *)errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedAlbumListDidSelectAlbum:(PhotoAlbum *)albumSelected {
    PhotoAlbumController *albumController = [[PhotoAlbumController alloc] initWithAlbum:albumSelected];
    albumController.delegate = self;
    albumController.nav = self.nav;
    [self.nav pushViewController:albumController animated:NO];
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

#pragma mark RevisitedCollViewDelegate methods

- (void) revisitedCollectionDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList {
    /*
    UploadingImagePreviewController *preview = [[UploadingImagePreviewController alloc] initWithUploadReference:squareRef.uploadRef withImage:squareRef.imgView.image];
    preview.oldDelegateRef = squareRef;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:preview];
    preview.nav = modalNav;
    [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
     */
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

- (void) revisitedCollectionDidFinishLoading {
}

- (void) revisitedCollectionDidFailRetrievingList:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedCollectionDidFailDeletingWithError:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedCollectionShouldShowLoading {
    [self showLoading];
}

- (void) revisitedCollectionShouldHideLoading {
    [self hideLoading];
}

- (void) revisitedCollectionChangeTitleTo:(NSString *) pageTitle {
    self.title = pageTitle;
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

- (void) revisitedGroupedPhotoDidFailRetrievingList:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoDidFailDeletingWithError:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) revisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle {
    self.title = pageTitle;
}

#pragma mark PhotoAlbumDelegate methods

- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [albumView pullData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(!collView.hidden) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"CollType"];
    } else if(!albumView.hidden) {
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

@end

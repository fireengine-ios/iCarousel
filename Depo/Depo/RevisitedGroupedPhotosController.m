//
//  RevisitedGroupedPhotosController.m
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedGroupedPhotosController.h"

@interface RevisitedGroupedPhotosController ()

@end

@implementation RevisitedGroupedPhotosController

@synthesize segmentView;
@synthesize groupView;
@synthesize collView;
@synthesize albumView;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        segmentView = [[RevisitedPhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        segmentView.delegate = self;
        [self.view addSubview:segmentView];
        
        groupView = [[RevisitedGroupedPhotoView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        [self.view addSubview:groupView];
        
        collView = [[RevisitedCollectionView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        collView.hidden = YES;
        [self.view addSubview:collView];

        albumView = [[RevisitedAlbumListView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        albumView.hidden = YES;
        albumView.delegate = self;
        [self.view addSubview:albumView];
        
        [albumView pullData];
    }
    return self;
}

- (void) revisitedPhotoHeaderSegmentPhotoChosen {
    groupView.hidden = NO;
    collView.hidden = YES;
    albumView.hidden = YES;
}

- (void) revisitedPhotoHeaderSegmentCollectionChosen {
    groupView.hidden = YES;
    collView.hidden = NO;
    albumView.hidden = YES;
}

- (void) revisitedPhotoHeaderSegmentAlbumChosen {
    groupView.hidden = YES;
    collView.hidden = YES;
    albumView.hidden = NO;
}

#pragma mark RevisitedAlbumListDelegate methods

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

#pragma mark PhotoAlbumDelegate methods
- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [albumView pullData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end

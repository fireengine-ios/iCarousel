//
//  PhotoAlbumController.m
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbumController.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "MetaFile.h"
#import "ImagePreviewController.h"
#import "VideoPreviewController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface PhotoAlbumController ()

@end

@implementation PhotoAlbumController

@synthesize album;
@synthesize photosScroll;
@synthesize photoList;
@synthesize moreMenuView;
@synthesize selectedFileList;
@synthesize footerActionMenu;

- (id)initWithAlbum:(PhotoAlbum *) _album {
    self = [super init];
    if (self) {
        self.album = _album;
        self.view.backgroundColor = [UIColor whiteColor];

        detailDao = [[AlbumDetailDao alloc] init];
        detailDao.delegate = self;
        detailDao.successMethod = @selector(albumDetailSuccessCallback:);
        detailDao.failMethod = @selector(albumDetailFailCallback:);
        
        renameDao = [[RenameAlbumDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);
        
        deleteDao = [[DeleteAlbumsDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        deleteImgDao = [[AlbumRemovePhotosDao alloc] init];
        deleteImgDao.delegate = self;
        deleteImgDao.successMethod = @selector(deleteImgSuccessCallback:);
        deleteImgDao.failMethod = @selector(deleteImgFailCallback:);
        
        selectedFileList = [[NSMutableArray alloc] init];

        photoList = [[NSMutableArray alloc] init];
        
        if(self.album.cover.tempDownloadUrl) {
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            [bgImgView setImageWithURL:[NSURL URLWithString:self.album.cover.tempDownloadUrl]];
            [self.view addSubview:bgImgView];
            
            UIImageView *maskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            maskImgView.image = [UIImage imageNamed:@"album_mask.png"];
            [self.view addSubview:maskImgView];
        } else {
            emptyBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            emptyBgImgView.image = [UIImage imageNamed:@"empty_album_header_bg.png"];
            [self.view addSubview:emptyBgImgView];
        }

        topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        topBgView.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        topBgView.hidden = YES;
        [self.view addSubview:topBgView];
        
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 30, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerBack) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:customBackButton];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(40, 35, self.view.frame.size.width - 80, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[UIColor whiteColor] withText:self.album.label];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];

        [self initAndSetSubTitle];
        
        moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 35, 20, 20) withImageName:@"dots_icon.png"];
        [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreButton];

        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, self.view.frame.size.height - 160)];
        [self.view addSubview:photosScroll];
        
        listOffset = 0;
        [detailDao requestDetailOfAlbum:self.album.uuid forStart:0 andSize:20];
        
        NSLog(@"FRAME: %@", NSStringFromCGRect(self.view.frame));

    }
    return self;
}

- (void) triggerRefresh {
    for(UIView *subview in [photosScroll subviews]) {
        if([subview isKindOfClass:[SquareImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    [photoList removeAllObjects];
    listOffset = 0;
    [detailDao requestDetailOfAlbum:self.album.uuid forStart:0 andSize:20];
}

- (void) initAndSetSubTitle {
    NSString *subTitleVal = @"";
    if(self.album.imageCount > 0 && self.album.videoCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitle", @""), self.album.imageCount, self.album.videoCount];
    } else if(self.album.imageCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitlePhotosOnly", @""), self.album.imageCount];
    } else if(self.album.videoCount > 0) {
        subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitleVideosOnly", @""), self.album.videoCount];
    }
    if(!subTitleLabel) {
        subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 124, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor] withText:subTitleVal];
        [self.view addSubview:subTitleLabel];
    } else {
        subTitleLabel.text = subTitleVal;
    }
}

- (void) albumDetailSuccessCallback:(NSArray *) contentList {
    int counter = [photoList count];
    for(MetaFile *row in contentList) {
        CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 5 + ((int)floor(counter/3)*105), 100, 100);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/3)+1)*105 + 20);
    [photoList addObjectsFromArray:contentList];
    isLoading = NO;
}

- (void) albumDetailFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(PhotoAlbum *) updatedAlbum {
    [self proceedSuccessForProgressView];
    self.album.label = updatedAlbum.label;
    self.album.lastModifiedDate = updatedAlbum.lastModifiedDate;

    titleLabel.text = [updatedAlbum label];
}

- (void) renameFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self.nav performSelector:@selector(postDelete) withObject:nil afterDelay:1.2f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    [self.nav popViewControllerAnimated:NO];
}

- (void) deleteImgSuccessCallback:(PhotoAlbum *) updatedAlbum {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressView];
    
    self.album.imageCount = updatedAlbum.imageCount;
    self.album.videoCount = updatedAlbum.videoCount;
    self.album.lastModifiedDate = updatedAlbum.lastModifiedDate;

    [self initAndSetSubTitle];
    [self triggerRefresh];
}

- (void) deleteImgFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    if(fileSelected.contentType == ContentTypePhoto) {
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    } else if(fileSelected.contentType == ContentTypeVideo) {
        VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileSelected];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    }
}

- (void) triggerBack {
    [self.nav popViewControllerAnimated:YES];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (void) triggerMore {
}

- (void) moreClicked {
    topBgView.hidden = NO;
    if(moreMenuView) {
        [moreMenuView removeFromSuperview];
    }
    
    moreMenuView = [[MoreMenuView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) withList:@[[NSNumber numberWithInt:MoreMenuTypeAlbumDetail], [NSNumber numberWithInt:MoreMenuTypeAlbumShare], [NSNumber numberWithInt:MoreMenuTypeAlbumDelete], [NSNumber numberWithInt:MoreMenuTypeSelect]] withFileFolder:nil withAlbum:self.album];
    moreMenuView.delegate = self;
    [self.view addSubview:moreMenuView];
    [self.view bringSubviewToFront:moreMenuView];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectAlbumShare {
}

- (void) moreMenuDidSelectAlbumDelete {
    [deleteDao requestDeleteAlbums:@[self.album.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
}

- (void) moreMenuDidDismiss {
    topBgView.hidden = YES;
}

#pragma mark AlbumDetailDelegate methods

- (void) albumDetailShouldRenameWithName:(NSString *)newName {
    [renameDao requestRenameAlbum:self.album.uuid withNewName:newName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumRenameProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumRenameSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumRenameFailMessage", @"")];
}

- (void) setSelectibleStatusForSquareImages:(BOOL) newStatus {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:newStatus];
        }
    }
}

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if(![selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList addObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
    } else {
        [self hideFooterMenu];
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) showFooterMenu {
    if(footerActionMenu) {
        footerActionMenu.hidden = NO;
    } else {
        footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES];
        footerActionMenu.delegate = self;
        [self.view addSubview:footerActionMenu];
    }
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    moreButton.hidden = YES;
    
    cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(moreButton.frame.origin.x-30, moreButton.frame.origin.y, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelSelectible) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedFileList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:YES];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    if(cancelButton) {
        [cancelButton removeFromSuperview];
    }
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    
    [APPDELEGATE.base immediateShowAddButton];
    
    [self setSelectibleStatusForSquareImages:NO];

    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
        footerActionMenu = nil;
    }
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            if([selectedFileList containsObject:sqView.file.uuid]) {
                [sqView showProgressMask];
            }
        }
    }
    [deleteImgDao requestRemovePhotos:selectedFileList fromAlbum:self.album.uuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end

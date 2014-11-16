//
//  PhotoListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoListController.h"
#import "ImagePreviewController.h"
#import "PreviewUnavailableController.h"
#import "PhotoAlbum.h"
#import "MainPhotoAlbumCell.h"
#import "PhotoAlbumController.h"
#import "VideoPreviewController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"

#define IMG_FOOTER_TAG 111
#define ALBUM_FOOTER_TAG 222

@interface PhotoListController ()

@end

@implementation PhotoListController

@synthesize headerView;
@synthesize photosScroll;
@synthesize photoList;
@synthesize refreshControl;
@synthesize albumList;
@synthesize albumTable;
@synthesize selectedFileList;
@synthesize selectedAlbumList;
@synthesize imgFooterActionMenu;
@synthesize albumFooterActionMenu;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");

        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);
        
        albumListDao = [[AlbumListDao alloc] init];
        albumListDao.delegate = self;
        albumListDao.successMethod = @selector(albumListSuccessCallback:);
        albumListDao.failMethod = @selector(albumListFailCallback:);
        
        addAlbumDao = [[AddAlbumDao alloc] init];
        addAlbumDao.delegate = self;
        addAlbumDao.successMethod = @selector(addAlbumSuccessCallback);
        addAlbumDao.failMethod = @selector(addAlbumFailCallback:);

        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        deleteAlbumDao = [[DeleteAlbumsDao alloc] init];
        deleteAlbumDao.delegate = self;
        deleteAlbumDao.successMethod = @selector(deleteAlbumSuccessCallback);
        deleteAlbumDao.failMethod = @selector(deleteAlbumFailCallback:);

        albumAddPhotosDao = [[AlbumAddPhotosDao alloc] init];
        albumAddPhotosDao.delegate = self;
        albumAddPhotosDao.successMethod = @selector(photosAddedSuccessCallback);
        albumAddPhotosDao.failMethod = @selector(photosAddedFailCallback:);
        
        selectedFileList = [[NSMutableArray alloc] init];
        selectedAlbumList = [[NSMutableArray alloc] init];

        photoList = [[NSMutableArray alloc] init];
        [photoList addObjectsFromArray:[APPDELEGATE.session uploadImageRefs]];
        
        normalizedContentHeight = self.view.frame.size.height - self.bottomIndex - 50;
        maximizedContentHeight = self.view.frame.size.height - self.bottomIndex + 14;
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex + 50, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];
        
        [self addOngoingPhotos];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControl];
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 50, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
//        albumTable.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        albumTable.tag = 222;
        albumTable.hidden = YES;
        [self.view addSubview:albumTable];

        headerView = [[PhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        headerView.delegate = self;
        [self.view addSubview:headerView];

        listOffset = 0;
        [elasticSearchDao requestPhotosForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [albumListDao requestAlbumListForStart:0 andSize:50];
        [self showLoading];

    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

- (void) addOngoingPhotos {
    if([photoList count] > 0) {
        int counter = 0;
        for(UploadRef *row in photoList) {
            CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 15 + ((int)floor(counter/3)*105), 100, 100);
            SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withUploadRef:row];
            [photosScroll addSubview:imgView];
            counter ++;
        }
        photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/3)+1)*105 + 20);
    }
}

- (void) setSelectibleStatusForSquareImages:(BOOL) newStatus {
    for(UIView *innerView in [photosScroll subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:newStatus];
        }
    }
}

- (void) triggerRefresh {
    [photoList removeAllObjects];
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [photoList addObjectsFromArray:[APPDELEGATE.session uploadImageRefs]];
    [self addOngoingPhotos];

    listOffset = 0;
    [elasticSearchDao requestPhotosForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 15 + ((int)floor(counter/3)*105), 100, 100);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/3)+1)*105 + 20);
    [photoList addObjectsFromArray:files];
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albumList = list;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addAlbumSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
    
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
}

- (void) deleteSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteAlbumSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressView];

    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) deleteAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photosAddedSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressView];
    
    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    albumTable.hidden = NO;
    photosScroll.hidden = YES;

    if(isSelectible) {
        [self hideImgFooterMenu];
        if([selectedAlbumList count] > 0) {
            [self showAlbumFooterMenu];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
        } else {
            [self hideAlbumFooterMenu];
            self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
        }
    }
}

- (void) photoHeaderDidSelectPhotosSegment {
    albumTable.hidden = YES;
    photosScroll.hidden = NO;

    if(isSelectible) {
        [self hideAlbumFooterMenu];
        if([selectedFileList count] > 0) {
            [self showImgFooterMenu];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
        } else {
            [self hideImgFooterMenu];
            self.title = NSLocalizedString(@"SelectFilesTitle", @"");
        }
    }
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

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if(![selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList addObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) showImgFooterMenu {
    if(imgFooterActionMenu) {
        imgFooterActionMenu.hidden = NO;
    } else {
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
        imgFooterActionMenu.tag = IMG_FOOTER_TAG;
        imgFooterActionMenu.delegate = self;
        [self.view addSubview:imgFooterActionMenu];
    }
}

- (void) hideImgFooterMenu {
    imgFooterActionMenu.hidden = YES;
}

- (void) showAlbumFooterMenu {
    if(albumFooterActionMenu) {
        albumFooterActionMenu.hidden = NO;
    } else {
        albumFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES];
        albumFooterActionMenu.tag = ALBUM_FOOTER_TAG;
        albumFooterActionMenu.delegate = self;
        [self.view addSubview:albumFooterActionMenu];
    }
}

- (void) hideAlbumFooterMenu {
    albumFooterActionMenu.hidden = YES;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 111) {
        if(!isLoading) {
            CGFloat currentOffset = photosScroll.contentOffset.y;
            CGFloat maximumOffset = photosScroll.contentSize.height - photosScroll.frame.size.height;
            
            if (currentOffset - maximumOffset >= 0.0) {
                isLoading = YES;
                [self dynamicallyLoadNextPage];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
    
    if(velocity.y > 0) {
        [self.nav showNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
        albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
    } else {
        [self.nav hideNavigationBar];
        photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, maximizedContentHeight);
        albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, maximizedContentHeight);
    }
    if(imgFooterActionMenu) {
        imgFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
    if(albumFooterActionMenu) {
        albumFooterActionMenu.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestPhotosForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [albumList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ALBUM_MAIN_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
        cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album isSelectible:isSelectible];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
    if(isSelectible) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[MainPhotoAlbumCell class]]) {
            if(![selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList addObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
                [self showAlbumFooterMenu];
                self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
            } else {
                [self hideAlbumFooterMenu];
                self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
            }
        }
    } else {
        PhotoAlbumController *albumController = [[PhotoAlbumController alloc] initWithAlbum:album];
        albumController.nav = self.nav;
        [self.nav pushViewController:albumController animated:NO];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible) {
        PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
        if([selectedAlbumList containsObject:album.uuid]) {
            [selectedAlbumList removeObject:album.uuid];
        }
        if([selectedAlbumList count] > 0) {
            [self showAlbumFooterMenu];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
        } else {
            [self hideAlbumFooterMenu];
            self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nav showNavigationBar];
    photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
    albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
    [addAlbumDao requestAddAlbumWithName:albumName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumAddFailMessage", @"")];
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        UploadManager *manager = [[UploadManager alloc] initWithUploadReference:ref];
        [manager startUploadingAsset:ref.filePath atFolder:nil];
        [APPDELEGATE.session.uploadManagers addObject:manager];
    }
    [self triggerRefresh];
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    if(albumTable.isHidden) {
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    } else {
        self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
    }

    previousButtonRef = self.navigationItem.leftBarButtonItem;
    
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelSelectible) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedFileList removeAllObjects];
    [selectedAlbumList removeAllObjects];
    
    [self setSelectibleStatusForSquareImages:YES];
    
    albumTable.allowsMultipleSelection = YES;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    [selectedAlbumList removeAllObjects];
    
    [APPDELEGATE.base immediateShowAddButton];
    
    [self setSelectibleStatusForSquareImages:NO];
    
    albumTable.allowsMultipleSelection = NO;
    self.tableUpdateCounter ++;
    [albumTable reloadData];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }
    if(albumFooterActionMenu) {
        [albumFooterActionMenu removeFromSuperview];
        albumFooterActionMenu = nil;
    }
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if(menu.tag == IMG_FOOTER_TAG) {
        for(UIView *innerView in [photosScroll subviews]) {
            if([innerView isKindOfClass:[SquareImageView class]]) {
                SquareImageView *sqView = (SquareImageView *) innerView;
                if([selectedFileList containsObject:sqView.file.uuid]) {
                    [sqView showProgressMask];
                }
            }
        }
        
        [deleteDao requestDeleteFiles:selectedFileList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        [deleteAlbumDao requestDeleteAlbums:selectedAlbumList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base showPhotoAlbums];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:albumUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumMovePhotoSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
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

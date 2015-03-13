//
//  PhotoListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoListController.h"
#import "PreviewUnavailableController.h"
#import "PhotoAlbum.h"
#import "MainPhotoAlbumCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import "MapUtil.h"

#define IMG_FOOTER_TAG 111
#define ALBUM_FOOTER_TAG 222

@interface PhotoListController ()

@end

@implementation PhotoListController

@synthesize headerView;
@synthesize photosScroll;
@synthesize photoList;
@synthesize refreshControlPhotos;
@synthesize refreshControlAlbums;
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
        [photoList addObjectsFromArray:[APPDELEGATE.uploadQueue uploadImageRefs]];
        
        normalizedContentHeight = self.view.frame.size.height - self.bottomIndex - 50;
        maximizedContentHeight = self.view.frame.size.height - self.bottomIndex + 14;
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex + 50, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];
        
        [self addOngoingPhotos];

        refreshControlPhotos = [[UIRefreshControl alloc] init];
        [refreshControlPhotos addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControlPhotos];
        
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

        refreshControlAlbums = [[UIRefreshControl alloc] init];
        [refreshControlAlbums addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [albumTable addSubview:refreshControlAlbums];

        headerView = [[PhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        headerView.delegate = self;
        [self.view addSubview:headerView];

        [self triggerRefresh];

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectionStateForAlbums:)];
        longPressGesture.minimumPressDuration = 1.0;
        [albumTable addGestureRecognizer:longPressGesture];
    
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(!albumTable.hidden) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    }
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

    /*
    listOffset = 0;
    [elasticSearchDao requestPhotosForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
    [albumListDao requestAlbumListForStart:0 andSize:50];
    [self showLoading];
     */
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

- (void) addOngoingPhotos {
    if (noItemCell != nil)
        [noItemCell removeFromSuperview];
    if([photoList count] > 0) {
        int counter = 0;
        for(UploadRef *row in photoList) {
            CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 15 + ((int)floor(counter/3)*105), 100, 100);
            SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withUploadRef:row];
            imgView.delegate = self;
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

- (void) selectionStateForAlbums:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:albumTable];
            NSIndexPath *indexPath = [albumTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                UITableViewCell *cell = [albumTable cellForRowAtIndexPath:indexPath];
                if (cell.isHighlighted) {
                    [self changeToSelectedStatus];
                }
            }
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
    
    [photoList addObjectsFromArray:[APPDELEGATE.uploadQueue uploadImageRefs]];
    [self addOngoingPhotos];

    listOffset = 0;
    self.tableUpdateCounter ++;

    [elasticSearchDao requestPhotosForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 15 + ((int)floor(counter/3)*105), 100, 100);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/3)+1)*105 + 20);
    [photoList addObjectsFromArray:files];
    if (photoList.count == 0) {
        if (noItemCell == nil)
            noItemCell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemCell];
    }
    else if (noItemCell != nil)
        [noItemCell removeFromSuperview];
    if(refreshControlPhotos) {
        [refreshControlPhotos endRefreshing];
    }
    if(refreshControlAlbums) {
        [refreshControlAlbums endRefreshing];
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
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
    
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
//    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
}

- (void) deleteSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteAlbumSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];

    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) deleteAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photosAddedSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    
    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:albumTable.hidden ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

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
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];

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

- (void) squareImageUploadFinishedForFile:(NSString *) fileUuid {
    if([[APPDELEGATE.uploadQueue uploadImageRefs] count] == 0) {
        [self triggerRefresh];
    }
}

- (void) squareImageWasLongPressedForFile:(MetaFile *)fileSelected {
    [self changeToSelectedStatus];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"QuotaExceedMessage", @"")];
}

- (void) squareImageUploadLoginError:(MetaFile *)fileSelected {
    [self showErrorAlertWithMessage:NSLocalizedString(@"LoginRequiredMessage", @"")];
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

    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView];
    if(translation.y > 0) {
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
    if(self.processView) {
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (void)sscrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
    NSLog(@"AT scrollViewWillBeginDragging: %.2f", velocity.y);
    
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
    if(self.processView) {
        self.processView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
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
    if (albumList.count == 0)
        return 1;
    return [albumList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ALBUM_MAIN_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if (albumList.count > 0) {
            PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
            cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album isSelectible:isSelectible];
        }
        else
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_album_icon" titleText:NSLocalizedString(@"EmptyAlbumsTitle", @"") descriptionText:NSLocalizedString(@"EmptyAlbumsDescription", @"")];
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
        albumController.delegate = self;
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
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [APPDELEGATE.uploadQueue addNewUploadTask:manager];
    }
    [self triggerRefresh];
}

- (void) postUploadTrigger {
    [APPDELEGATE.base hideBaseLoading];
    [self triggerRefresh];
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filePath withName:(NSString *)fileName {
    UploadRef *uploadRef = [[UploadRef alloc] init];
    uploadRef.tempUrl = filePath;
    uploadRef.fileName = fileName;
    uploadRef.contentType = ContentTypePhoto;
    
    UploadManager *uploadManager = [[UploadManager alloc] initWithUploadInfo:uploadRef];
    [uploadManager configureUploadFileForPath:filePath atFolder:nil withFileName:fileName];
    [APPDELEGATE.uploadQueue addNewUploadTask:uploadManager];
    
    [self triggerRefresh];
}

- (void) moreClicked {
    if(albumTable.isHidden) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
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
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void) cancelClicked {
    [self cancelSelectible];
    [APPDELEGATE.base immediateShowAddButton];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"PhotosTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedFileList removeAllObjects];
    [selectedAlbumList removeAllObjects];
    
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

#pragma mark ImagePreviewDelegate methods
- (void) previewedImageWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
}

#pragma mark VideoPreviewDelegate methods
- (void) previewedVideoWasDeleted:(MetaFile *)deletedFile {
    [self triggerRefresh];
}

#pragma mark PhotoAlbumDelegate methods
- (void) photoAlbumDidChange:(NSString *)albumUuid {
    [self triggerRefresh];
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
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
    } else {
        if(menu.tag == IMG_FOOTER_TAG) {
            self.deleteType = DeleteTypePhotos;
        } else {
            self.deleteType = DeleteTypeAlbums;
        }
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base showPhotoAlbums];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base triggerShareForFiles:selectedFileList];
}

- (void) albumModalDidSelectAlbum:(NSString *)albumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:albumUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"AlbumMovePhotoSuccessMessage", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];

}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
    NSLog(@"At INNER confirmDeleteDidCancel");
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypePhotos) {
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
    } else if(self.deleteType == DeleteTypeAlbums) {
        [deleteAlbumDao requestDeleteAlbums:selectedAlbumList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteAlbumProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteAlbumSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteAlbumFailMessage", @"")];
    }
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

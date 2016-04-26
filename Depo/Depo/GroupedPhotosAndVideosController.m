//
//  GroupedPhotosAndVideosController.m
//  Depo
//
//  Created by Mahir Tarlan on 26/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupedPhotosAndVideosController.h"
#import "PreviewUnavailableController.h"
#import "PhotoAlbum.h"
#import "MainPhotoAlbumCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import "MapUtil.h"
#import "UploadingImagePreviewController.h"
#import "PrintWebViewController.h"
#import "UIImageView+AFNetworking.h"
#import "NoItemView.h"
#import "GroupedPhotosCell.h"

#define IMG_FOOTER_TAG 111
#define ALBUM_FOOTER_TAG 222

@interface GroupedPhotosAndVideosController ()

@end

@implementation GroupedPhotosAndVideosController

@synthesize groups;
@synthesize refreshControl;
@synthesize headerView;
@synthesize albumList;
@synthesize mainTable;
@synthesize selectedFileList;
@synthesize selectedAlbumList;
@synthesize imgFooterActionMenu;
@synthesize albumFooterActionMenu;
@synthesize photoCount;
@synthesize level;
@synthesize segmentType;

- (id) init {
    return [self initWithLevel:ImageGroupLevelYear];
}

- (id) initWithLevel:(ImageGroupLevel) levelVal {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        self.level = levelVal;
        
        groupDao = [[SearchByGroupDao alloc] init];
        groupDao.delegate = self;
        groupDao.successMethod = @selector(groupSuccessCallback:);
        groupDao.failMethod = @selector(groupFailCallback:);

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
        
        photoCount = 0;
        
        albumTableUpdateCounter = 0;
        photoTableUpdateCounter = 0;
        
        groups = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        selectedAlbumList = [[NSMutableArray alloc] init];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        
        mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 50) style:UITableViewStylePlain];
        mainTable.backgroundColor = [UIColor clearColor];
        mainTable.backgroundView = nil;
        mainTable.delegate = self;
        mainTable.dataSource = self;
        mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mainTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [mainTable addSubview:refreshControl];
        
        headerView = [[PhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        headerView.delegate = self;
        [self.view addSubview:headerView];
        
        [self triggerRefresh];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(triggerSelectionState:)];
        longPressGesture.minimumPressDuration = 1.0;
        [mainTable addGestureRecognizer:longPressGesture];
    }
    return self;
}

- (void) groupSuccessCallback:(NSArray *) fileGroups {
    [self hideLoading];
    [self.groups addObjectsFromArray:fileGroups];

    photoTableUpdateCounter ++;
    [mainTable reloadData];
}

- (void) groupFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    }
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

/*
- (void) addOngoingPhotos {
    if (noItemView != nil)
        [noItemView removeFromSuperview];
    if([photoList count] > 0) {
        int counter = 0;
        
        int imagePerLine = 3;
        
        float imageWidth = 100;
        float interImageMargin = 5;
        
        if(IS_IPAD) {
            imagePerLine = 5;
            imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
        }
        
        float imageTotalWidth = imageWidth + interImageMargin;
        
        for(UploadRef *row in photoList) {
            CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
            SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withUploadRef:row];
            imgView.delegate = self;
            [photosScroll addSubview:imgView];
            counter ++;
        }
        float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
        if(contentSizeHeight <= photosScroll.frame.size.height) {
            contentSizeHeight = photosScroll.frame.size.height + 1;
        }
        photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    }
}
*/

- (void) triggerSelectionState:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible && segmentType == PhotoHeaderSegmentTypeAlbum) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:mainTable];
            NSIndexPath *indexPath = [mainTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                UITableViewCell *cell = [mainTable cellForRowAtIndexPath:indexPath];
                if (cell.isHighlighted) {
                    [self changeToSelectedStatus];
                }
            }
        }
    }
}

- (void) triggerRefresh {
    [groups removeAllObjects];
    if (isSelectible) {
        [selectedFileList removeAllObjects];
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }

    albumListOffset = 0;
    photoListOffset = 0;
    
    albumTableUpdateCounter ++;
    photoTableUpdateCounter ++;
    
    [groupDao requestImagesByGroupByPage:photoListOffset bySize:100 byLevel:self.level byGroupDate:nil byGroupSize:[NSNumber numberWithInt:50]];
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) alignPhotosScrollPostDelete {
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albumList = list;
    albumTableUpdateCounter ++;
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        [mainTable reloadData];
    }
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addAlbumSuccessCallback {
    [self proceedSuccessForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
}

- (void) deleteSuccessCallback {
    [self alignPhotosScrollPostDelete];
    
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteAlbumSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    
    albumTableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) deleteAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photosAddedSuccessCallback {
    if(isSelectible) {
        [self cancelSelectible];
    }
    
    [self proceedSuccessForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    
    albumTableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressViewWithAddButtonKey:segmentType == PhotoHeaderSegmentTypePhoto ? @"PhotoTab" : @"AlbumTab"];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    segmentType = PhotoHeaderSegmentTypeAlbum;
    
    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"AlbumTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
    
    [mainTable reloadData];
    
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
    segmentType = PhotoHeaderSegmentTypePhoto;

    NSArray *addTypesForController = [APPDELEGATE.mapUtil readAddTypesByController:@"PhotoTab"];
    [APPDELEGATE.base modifyAddButtonWithList:addTypesForController];
    
    [mainTable reloadData];
    
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

- (void) squareImageWasSelectedForView:(SquareImageView *) squareRef {
    UploadingImagePreviewController *preview = [[UploadingImagePreviewController alloc] initWithUploadReference:squareRef.uploadRef withImage:squareRef.imgView.image];
    preview.oldDelegateRef = squareRef;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:preview];
    preview.nav = modalNav;
    [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    if(fileSelected.contentType == ContentTypePhoto) {
        NSMutableArray *filteredPhotoList = [[NSMutableArray alloc] init];
        [filteredPhotoList addObject:fileSelected];

        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFiles:filteredPhotoList withImage:fileSelected withListOffset:photoListOffset];
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
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        [self hideImgFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
    if (fileSelected.contentType == ContentTypeVideo) {
        if (photoCount == 0) {
            [imgFooterActionMenu hidePrintIcon];
        }
        else{
            [imgFooterActionMenu showPrintIcon];
        }
    }
    else {
        photoCount++;
        [imgFooterActionMenu showPrintIcon];
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
    if (fileSelected.contentType == ContentTypePhoto) {
        photoCount--;
    }
    if (photoCount == 0) {
        [imgFooterActionMenu hidePrintIcon];
    }
}

- (BOOL) checkIfSelectedFileListContainsPhoto {
    if (photoCount > 0) {
        return YES;
    }
    else {
        return NO;
    }
}


- (void) squareImageUploadFinishedForFile:(NSString *) fileUuid {
    if([[[UploadQueue sharedInstance] uploadImageRefs] count] == 0) {
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
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:YES isMoveAlbum:YES];
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
        albumFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES shouldShowPrint:NO];
        albumFooterActionMenu.tag = ALBUM_FOOTER_TAG;
        albumFooterActionMenu.delegate = self;
        [self.view addSubview:albumFooterActionMenu];
    }
}

- (void) hideAlbumFooterMenu {
    albumFooterActionMenu.hidden = YES;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void) dynamicallyLoadNextPage {
    if(segmentType == PhotoHeaderSegmentTypePhoto) {
        photoListOffset ++;
        [groupDao requestImagesByGroupByPage:photoListOffset bySize:100 byLevel:self.level byGroupDate:nil byGroupSize:[NSNumber numberWithInt:50]];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        return self.view.frame.size.width/2;
    } else {
        return self.view.frame.size.width/2;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        if (albumList.count == 0)
            return 1;
        return [albumList count];
    } else {
        if (groups.count == 0)
            return 1;
        return [groups count];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d",segmentType == PhotoHeaderSegmentTypePhoto ? @"PHOTOS_CELL" : @"ALBUM_CELL",  (int)indexPath.row, segmentType == PhotoHeaderSegmentTypeAlbum ? albumTableUpdateCounter : photoTableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if(segmentType == PhotoHeaderSegmentTypePhoto) {
            if(groups.count > 0) {
                FileInfoGroup *group = [groups objectAtIndex:indexPath.row];
                cell = [[GroupedPhotosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withGroup:group];
            } else {
                cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
            }
        } else {
            if (albumList.count > 0) {
                PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
                cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album isSelectible:isSelectible];
            } else {
                cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_album_icon" titleText:NSLocalizedString(@"EmptyAlbumsTitle", @"") descriptionText:NSLocalizedString(@"EmptyAlbumsDescription", @"")];
            }
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        if(albumList == nil || [albumList count] == 0) {
            return;
        }
        
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
    } else {
        //TODO image group select
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        if(isSelectible) {
            if(!albumList || [albumList count] == 0) {
                return;
            }
            if([albumList count] > indexPath.row) {
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
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
    [addAlbumDao requestAddAlbumWithName:albumName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumAddFailMessage", @"")];
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
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
    uploadRef.ownerPage = UploadStarterPagePhotos;
    uploadRef.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
    
    UploadManager *uploadManager = [[UploadManager alloc] initWithUploadInfo:uploadRef];
    [uploadManager configureUploadFileForPath:filePath atFolder:nil withFileName:fileName];
    [[UploadQueue sharedInstance] addNewUploadTask:uploadManager];
    
    [self triggerRefresh];
    
    [[CurioSDK shared] sendEvent:@"ImageCapture" eventValue:@"true"];
}

- (void) moreClicked {
    if(segmentType == PhotoHeaderSegmentTypePhoto) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort]]];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSortWithList], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
}

- (void) moreMenuDidSelectSortWithList {
    [APPDELEGATE.base showSortWithList:[NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeAlphaAsc], [NSNumber numberWithInt:SortTypeAlphaDesc], [NSNumber numberWithInt:SortTypeDateAsc], [NSNumber numberWithInt:SortTypeDateDesc], nil]];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        isSelectible = YES;
        [headerView deactivate];
        
        self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");

        previousButtonRef = self.navigationItem.leftBarButtonItem;
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        moreButton.hidden = YES;
        
        [APPDELEGATE.base immediateHideAddButton];
        
        [selectedFileList removeAllObjects];
        [selectedAlbumList removeAllObjects];
        
        mainTable.allowsMultipleSelection = YES;
        albumTableUpdateCounter ++;
        [mainTable reloadData];
    }
}

- (void) cancelClicked {
    [self cancelSelectible];
    [APPDELEGATE.base immediateShowAddButton];
}

- (void) cancelSelectible {
    if(segmentType == PhotoHeaderSegmentTypeAlbum) {
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        self.navigationItem.leftBarButtonItem = previousButtonRef;
        moreButton.hidden = NO;
        
        isSelectible = NO;
        [headerView reactivate];

        [selectedFileList removeAllObjects];
        [selectedAlbumList removeAllObjects];
        
        mainTable.allowsMultipleSelection = NO;
        albumTableUpdateCounter ++;
        [mainTable reloadData];
        
        if(imgFooterActionMenu) {
            [imgFooterActionMenu removeFromSuperview];
            imgFooterActionMenu = nil;
        }
        if(albumFooterActionMenu) {
            [albumFooterActionMenu removeFromSuperview];
            albumFooterActionMenu = nil;
        }
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
    [APPDELEGATE.base immediateShowAddButton];
    [self triggerRefresh];
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        if(menu.tag == IMG_FOOTER_TAG) {
            //TODO image delete nasıl olacak
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
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];
    
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
    PrintWebViewController *printController = [[PrintWebViewController alloc] initWithUrl:@"http://akillidepo.cellograf.com/" withFileList:selectedFileList];
    printNav = [[MyNavigationController alloc] initWithRootViewController:printController];
    
    [self presentViewController:printNav animated:YES completion:nil];
}

- (void) closePrintPage {
    [printNav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypePhotos) {
        //TODO image delete nasıl olacak
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

- (void) dealloc {
    //mahir
    [UIImageView clearImageCaches];
}

@end

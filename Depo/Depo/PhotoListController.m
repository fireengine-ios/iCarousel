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

@interface PhotoListController ()

@end

@implementation PhotoListController

@synthesize headerView;
@synthesize photosScroll;
@synthesize photoList;
@synthesize refreshControl;
@synthesize albumList;
@synthesize albumTable;

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
        [elasticSearchDao requestPhotosForPage:listOffset andSize:21];
        [albumListDao requestAlbumListForStart:0 andSize:50];
        [self showLoading];

    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    [elasticSearchDao requestPhotosForPage:listOffset andSize:21];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = [photoList count];
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
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addAlbumSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
    
    self.tableUpdateCounter ++;
    [albumListDao requestAlbumListForStart:0 andSize:50];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    albumTable.hidden = NO;
    photosScroll.hidden = YES;
}

- (void) photoHeaderDidSelectPhotosSegment {
    albumTable.hidden = YES;
    photosScroll.hidden = NO;
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
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestPhotosForPage:listOffset andSize:21];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [albumList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ALBUM_MAIN_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
        cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
    PhotoAlbumController *albumController = [[PhotoAlbumController alloc] initWithAlbum:album];
    albumController.nav = self.nav;
    [self.nav pushViewController:albumController animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nav showNavigationBar];
    photosScroll.frame = CGRectMake(photosScroll.frame.origin.x, photosScroll.frame.origin.y, photosScroll.frame.size.width, normalizedContentHeight);
    albumTable.frame = CGRectMake(albumTable.frame.origin.x, albumTable.frame.origin.y, albumTable.frame.size.width, normalizedContentHeight);
}

- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *)albumName {
    [addAlbumDao requestAddAlbumWithName:albumName];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FolderAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FolderAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FolderAddFailMessage", @"")];
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        UploadManager *manager = [[UploadManager alloc] initWithUploadReference:ref];
        [manager startUploadingAsset:ref.filePath atFolder:nil];
        [APPDELEGATE.session.uploadManagers addObject:manager];
    }
    [self triggerRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

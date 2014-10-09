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

        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(photoListSuccessCallback:);
        fileListDao.failMethod = @selector(photoListFailCallback:);
        
        albumListDao = [[AlbumListDao alloc] init];
        albumListDao.delegate = self;
        albumListDao.successMethod = @selector(albumListSuccessCallback:);
        albumListDao.failMethod = @selector(albumListFailCallback:);
        
        headerView = [[PhotoHeaderSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        headerView.delegate = self;
        [self.view addSubview:headerView];
        
        photoList = [[NSMutableArray alloc] init];
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerView.frame.origin.y + headerView.frame.size.height + 5, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.origin.y - headerView.frame.size.height - 5 - self.bottomIndex)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [photosScroll addSubview:refreshControl];
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, headerView.frame.origin.y + headerView.frame.size.height + 5, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.origin.y - headerView.frame.size.height - 5 - self.bottomIndex) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        albumTable.tag = 222;
        albumTable.hidden = YES;
        [self.view addSubview:albumTable];

        listOffset = 0;
        [fileListDao requestPhotosForOffset:listOffset andSize:20];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) triggerRefresh {
    [photoList removeAllObjects];
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    listOffset = 0;
    [fileListDao requestPhotosForOffset:listOffset andSize:20];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    int counter = [photoList count];
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(5 + (counter%3 * 105), ((int)floor(counter/3)*105), 100, 100);
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
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albumList = list;
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) photoHeaderDidSelectAlbumsSegment {
    albumTable.hidden = NO;
    photosScroll.hidden = YES;
    
    if(albumList == nil) {
        [albumListDao requestAlbumListForStart:0 andSize:50];
    }
}

- (void) photoHeaderDidSelectPhotosSegment {
    albumTable.hidden = YES;
    photosScroll.hidden = NO;
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected];
    detail.nav = self.nav;
    [self.nav pushViewController:detail animated:NO];
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

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [fileListDao requestPhotosForOffset:listOffset andSize:20];
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

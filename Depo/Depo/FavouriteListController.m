//
//  FavouriteListController.m
//  Depo
//
//  Created by NCO on 07/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FavouriteListController.h"
#import "AppDelegate.h"
#import "FolderEmptyCell.h"
#import "FolderCell.h"
#import "MusicCell.h"
#import "SimpleMusicCell.h"
#import "ImageCell.h"
#import "DocCell.h"
#import "MusicPreviewController.h"
#import "ImagePreviewController.h"
#import "FileListController.h"
#import "FileDetailInWebViewController.h"
#import "VideoPreviewController.h"
#import "PreviewUnavailableController.h"
#import "MessageCell.h"
#import "BaseViewController.h"

@interface FavouriteListController ()

@end

@implementation FavouriteListController

@synthesize fileTable;
@synthesize refreshControl;
@synthesize fileList;

- (id) init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"FavouritesTitle", @"");
        
        fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        fileTable.delegate = self;
        fileTable.dataSource = self;
        fileTable.backgroundColor = [UIColor clearColor];
        fileTable.backgroundView = nil;
        fileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:fileTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [fileTable addSubview:refreshControl];
        
        listDao = [[FavoriteDao alloc] init];
        listDao.delegate = self;
        listDao.successMethod = @selector(favListSuccessCallback:);
        listDao.failMethod = @selector(favListFailCallback:);
        
        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback);
        favoriteDao.failMethod = @selector(favFailCallback:);
        
    }
    
    return self;
}

- (void) triggerRefresh {
    listOffset = 0;
    isFirstLoad = YES;
    [fileList removeAllObjects];
    self.tableUpdateCounter++;
    [listDao requestMetadata:listOffset andSize:NO_OF_FILES_PER_PAGE andSortType:APPDELEGATE.session.sortType];
}

- (void) favListSuccessCallback:(NSArray *) files {
    if (fileList == nil)
        fileList = [[NSMutableArray alloc] init];
    else if (isFirstLoad)
        [fileList removeAllObjects];
    
    [fileList addObjectsFromArray:files];
    self.tableUpdateCounter++;
    [fileTable reloadData];
    
    if (refreshControl)
        [refreshControl endRefreshing];
    [super hideLoading];
    isLoading = NO;
    isFirstLoad = NO;
}

- (void) favListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) favSuccessCallback {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(fileList == nil) {
        return 0;
    } else if([fileList count] == 0) {
        return 1;
    } else {
        return [fileList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(fileList == nil || [fileList count] == 0) {
        return 320;
    } else {
        return 68;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"FILE_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if (fileList != nil && [fileList count] != 0) {
            id objAtIndex = [fileList objectAtIndex:indexPath.row];
            
            MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
            switch (fileAtIndex.contentType) {
                case ContentTypeFolder:
                    cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                    break;
                case ContentTypePhoto:
                case ContentTypeVideo:
                    cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                    break;
                case ContentTypeMusic:
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                    break;
                default:
                    cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                    break;
            }
            ((AbstractFileFolderCell *) cell).delegate = self;
        }
        else if (fileList == nil) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ConnectionErrorWarning", @"")];
        }
        else if ([fileList count] == 0) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"NoFavouriteFound", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaFile *fileAtIndex = [fileList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    if(fileAtIndex.contentType == ContentTypeFolder) {
        FileListController *innerList = [[FileListController alloc] initForFolder:fileAtIndex];
        innerList.nav = self.nav;
        [self.nav pushViewController:innerList animated:NO];
    } else {
        if([AppUtil isMetaFileImage:fileAtIndex]) {
            ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileAtIndex];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileDoc:fileAtIndex]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileVideo:fileAtIndex]) {
            VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileAtIndex];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
            detail.nav = modalNav;
            [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
        } else if([AppUtil isMetaFileMusic:fileAtIndex]) {
            MusicPreviewController *detail = [[MusicPreviewController alloc] initWithFile:fileAtIndex.uuid withFileList:@[fileAtIndex]];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else {
            PreviewUnavailableController *detail = [[PreviewUnavailableController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        }
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = fileTable.contentOffset.y;
        CGFloat maximumOffset = fileTable.contentSize.height - fileTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [listDao requestMetadata:listOffset andSize:NO_OF_FILES_PER_PAGE andSortType:APPDELEGATE.session.sortType];
}

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:YES];
    //    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:NO];
    //    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self triggerRefresh];
    [self showLoading];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

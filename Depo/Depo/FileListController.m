//
//  FileListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileListController.h"
#import "FolderCell.h"
#import "MusicCell.h"
#import "ImageCell.h"
#import "DocCell.h"
#import "CustomButton.h"
#import "FolderEmptyCell.h"
#import "FileDetailInWebViewController.h"
#import "AppUtil.h"
#import "ImagePreviewController.h"
#import "PreviewUnavailableController.h"
#import "UploadRef.h"
#import "UploadingImageCell.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface FileListController ()

@end

@implementation FileListController

@synthesize folder;
@synthesize fileTable;
@synthesize refreshControl;
@synthesize fileList;

- (id)initForFolder:(MetaFile *) _folder {
    self = [super init];
    if (self) {
        self.folder = _folder;
        listOffset = 0;

        if(self.folder) {
            self.title = self.folder.visibleName;
        } else {
            self.title = NSLocalizedString(@"FilesTitle", @"");
        }

        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(fileListSuccessCallback:);
        fileListDao.failMethod = @selector(fileListFailCallback:);
        
        loadMoreDao = [[FileListDao alloc] init];
        loadMoreDao.delegate = self;
        loadMoreDao.successMethod = @selector(loadMoreSuccessCallback:);
        loadMoreDao.failMethod = @selector(loadMoreFailCallback:);
        
        addFolderDao = [[AddFolderDao alloc] init];
        addFolderDao.delegate = self;
        addFolderDao.successMethod = @selector(addFolderSuccessCallback);
        addFolderDao.failMethod = @selector(addFolderFailCallback:);
        
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

        if(self.folder) {
            [fileListDao requestFileListingForFolder:self.folder.name andForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
        } else {
            [fileListDao requestFileListingForParentForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
        }
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) triggerRefresh {
    listOffset = 0;
    if(self.folder) {
        [fileListDao requestFileListingForFolder:self.folder.name andForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    } else {
        [fileListDao requestFileListingForParentForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    }
}

- (void) fileListSuccessCallback:(NSArray *) files {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    self.fileList = [[APPDELEGATE.session uploadRefsForFolder:[self.folder name]] arrayByAddingObjectsFromArray:files];
    self.tableUpdateCounter ++;
    [fileTable reloadData];
}

- (void) fileListFailCallback:(NSString *) errorMessage {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) loadMoreSuccessCallback:(NSArray *) files {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    self.fileList = [fileList arrayByAddingObjectsFromArray:files];
    isLoading = NO;
    self.tableUpdateCounter ++;
    [fileTable reloadData];
}

- (void) loadMoreFailCallback:(NSString *) errorMessage {
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) addFolderSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];

    listOffset = 0;
    if(self.folder) {
        [fileListDao requestFileListingForFolder:self.folder.name andForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    } else {
        [fileListDao requestFileListingForParentForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    }
}

- (void) addFolderFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self performSelector:@selector(popProgressView) withObject:nil afterDelay:1.0f];
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
        if(fileList == nil || [fileList count] == 0) {
            cell = [[FolderEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFolderTitle:self.folder.visibleName];
        } else {
            id objAtIndex = [fileList objectAtIndex:indexPath.row];
            if([objAtIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
                switch (fileAtIndex.contentType) {
                    case ContentTypeFolder:
                        cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                        break;
                    case ContentTypePhoto:
                        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                        break;
                    case ContentTypeMusic:
                        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                        break;
                    default:
                        cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex];
                        break;
                }
            } else {
                UploadRef *refAtIndex = (UploadRef *) objAtIndex;
                cell = [[UploadingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withUploadRef:refAtIndex atFolder:[self.folder name]];
            }
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaFile *fileAtIndex = [fileList objectAtIndex:indexPath.row];
    
    if(fileAtIndex.contentType == ContentTypeFolder) {
        FileListController *innerList = [[FileListController alloc] initForFolder:fileAtIndex];
        innerList.nav = self.nav;
        [self.nav pushViewController:innerList animated:NO];
    } else {
        if([AppUtil isMetaFileImage:fileAtIndex]) {
            ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileAtIndex];
            detail.nav = self.nav;
            [self.nav pushViewController:detail animated:NO];
        } else if([AppUtil isMetaFileDoc:fileAtIndex] || [AppUtil isMetaFileVideo:fileAtIndex] || [AppUtil isMetaFileMusic:fileAtIndex]){
            FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
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
    if(self.folder) {
        [loadMoreDao requestFileListingForFolder:self.folder.name andForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    } else {
        [loadMoreDao requestFileListingForParentForOffset:listOffset*NO_OF_FILES_PER_PAGE andSize:NO_OF_FILES_PER_PAGE];
    }
}

- (void) moreClicked {
    if(self.folder) {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeDetail], [NSNumber numberWithInt:MoreMenuTypeShare], [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDelete], [NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    } else {
        [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CustomButton *moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) newFolderModalDidTriggerNewFolderWithName:(NSString *)folderName {
    [addFolderDao requestAddFolderAtPath:[self appendNewFileName:folderName]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FolderAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FolderAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FolderAddFailMessage", @"")];
}

- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *)filepath {
    uploadManager = [[UploadManager alloc] init];
    [uploadManager startUploadingFile:filepath atFolder:nil withFileName:@"fromCam.png"];
}

- (NSString *) appendNewFileName:(NSString *) newFileName {
    if(self.folder) {
        if([self.folder.name hasSuffix:@"/"]) {
            return [AppUtil enrichFileFolderName:[NSString stringWithFormat:@"%@%@", self.folder.name, newFileName]];
        } else {
            return [AppUtil enrichFileFolderName:[NSString stringWithFormat:@"%@/%@", self.folder.name, newFileName]];
        }
    } else {
        return [AppUtil enrichFileFolderName:newFileName];
    }
}

- (void) photoModalDidTriggerUploadForUrls:(NSArray *)assetUrls {
    for(UploadRef *ref in assetUrls) {
        UploadManager *manager = [[UploadManager alloc] init];
        ref.folderName = [self.folder name];
        manager.uploadRef = ref;
        [manager startUploadingAsset:ref.filePath atFolder:self.folder];
        [APPDELEGATE.session.uploadManagers addObject:manager];
    }
    fileList = [assetUrls arrayByAddingObjectsFromArray:fileList];
    self.tableUpdateCounter++;
    [self.fileTable reloadData];
}

@end

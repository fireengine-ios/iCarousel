//
//  FileListController.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FileListDao.h"
#import "MetaFile.h"
#import "AddFolderDao.h"
#import "UploadManager.h"

@interface FileListController : MyViewController <UITableViewDelegate, UITableViewDataSource> {
    FileListDao *fileListDao;
    FileListDao *loadMoreDao;
    AddFolderDao *addFolderDao;
    UploadManager *uploadManager;

    int listOffset;
    BOOL isLoading;
}

@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UITableView *fileTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *fileList;

- (id)initForFolder:(MetaFile *) _folder;

@end

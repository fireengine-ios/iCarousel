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

@interface FileListController : MyViewController <UITableViewDelegate, UITableViewDataSource> {
    FileListDao *fileListDao;
}

@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UITableView *fileTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *fileList;

- (id)initForFolder:(MetaFile *) _folder;

@end

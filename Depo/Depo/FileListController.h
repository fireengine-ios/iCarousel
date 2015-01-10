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
#import "AbstractFileFolderCell.h"
#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "FooterActionsMenuView.h"
#import "MoveDao.h"
#import "RenameDao.h"

@interface FileListController : MyViewController <UITableViewDelegate, UITableViewDataSource, AbstractFileFolderDelegate, FooterActionsDelegate> {
    FileListDao *fileListDao;
    FileListDao *loadMoreDao;
    AddFolderDao *addFolderDao;
    DeleteDao *deleteDao;
    DeleteDao *folderDeleteDao;
    FavoriteDao *favoriteDao;
    FavoriteDao *folderFavDao;
    MoveDao *moveDao;
    RenameDao *renameDao;
    
    MetaFile *fileSelectedRef;
    
    UploadManager *uploadManager;
    CustomButton *moreButton;
    
    UIBarButtonItem *previousButtonRef;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UITableView *fileTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *fileList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;

- (id)initForFolder:(MetaFile *) _folder;

@end

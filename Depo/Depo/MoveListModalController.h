//
//  MoveListModalController.h
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "FileListDao.h"
#import "MetaFile.h"
#import "MoveModalFooterView.h"

@protocol MoveListModalProtocol <NSObject>
- (void) moveListModalDidSelectFolder:(NSString *) folderUuid;
@end

@interface MoveListModalController : MyModalController <UITableViewDataSource, UITableViewDelegate, MoveModalFooterDelegate> {
    FileListDao *fileListDao;
}

@property (nonatomic, strong) id<MoveListModalProtocol> delegate;
@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UITableView *folderTable;
@property (nonatomic, strong) NSArray *folderList;
@property (nonatomic, strong) MoveModalFooterView *footerView;

- (id)initForFolder:(MetaFile *) _folder;

@end

//
//  PhotoAlbumListModalController.h
//  Depo
//
//  Created by Mahir on 12.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "AlbumListDao.h"

@protocol AlbumModalDelete <NSObject>
- (void) albumModalDidSelectAlbum:(NSString *) albumUuid;
@end

@interface PhotoAlbumListModalController : MyModalController <UITableViewDataSource, UITableViewDelegate> {
    AlbumListDao *albumsDao;
}

@property (nonatomic, weak) id<AlbumModalDelete> delegate;
@property (nonatomic, strong) UITableView *albumTable;
@property (nonatomic, strong) NSArray *albumList;

@end

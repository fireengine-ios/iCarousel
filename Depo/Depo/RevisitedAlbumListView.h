//
//  RevisitedAlbumListView.h
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAlbum.h"
#import "AlbumListDao.h"

@protocol RevisitedAlbumListDelegate <NSObject>
- (void) revisitedAlbumListDidSelectAlbum:(PhotoAlbum *) albumSelected;
- (void) revisitedAlbumListDidFinishLoading;
- (void) revisitedAlbumListDidFailRetrievingList:(NSString *) errorMessage;
@end

@interface RevisitedAlbumListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<RevisitedAlbumListDelegate> delegate;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) UITableView *albumTable;
@property (nonatomic, strong) AlbumListDao *albumsDao;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *selectedAlbumList;
@property (nonatomic) BOOL isSelectible;

- (void) pullData;

@end

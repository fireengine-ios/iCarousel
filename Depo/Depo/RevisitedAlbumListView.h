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
#import "DeleteAlbumsDao.h"
#import "FooterActionsMenuView.h"
#import "MBProgressHUD.h"
#import "AddAlbumDao.h"
#import "ConfirmDeleteModalController.h"

@protocol RevisitedAlbumListDelegate <NSObject>
- (void) revisitedAlbumListDidSelectAlbum:(PhotoAlbum *) albumSelected;
- (void) revisitedAlbumListShareAlbums:(NSArray *)albumUUIDs;
- (void) revisitedAlbumListDownloadAlbums:(NSArray *)albumUUIDs albumNames:(NSArray *)albumNames;
- (void) revisitedAlbumListDidFinishLoading;
- (void) revisitedAlbumListDidFinishDeleting;
- (void) revisitedAlbumListDidChangeToSelectState;
- (void) revisitedAlbumListDidFailRetrievingList:(NSString *) errorMessage;
- (void) revisitedAlbumListDidFailDeletingWithError:(NSString *) errorMessage;
- (void) revisitedAlbumListChangeTitleTo:(NSString *) pageTitle;
@end

@interface RevisitedAlbumListView : UIView <UITableViewDataSource, UITableViewDelegate, FooterActionsDelegate, ConfirmDeleteDelegate>

@property (nonatomic, weak) id<RevisitedAlbumListDelegate> delegate;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) UITableView *albumTable;
@property (nonatomic, strong) AlbumListDao *albumsDao;
@property (nonatomic, strong) DeleteAlbumsDao *deleteAlbumDao;
@property (nonatomic, strong) AddAlbumDao *addAlbumDao;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *selectedAlbumList;

@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;
@property (nonatomic) BOOL isSelectible;

@property (nonatomic, strong) MBProgressHUD *progress;

- (void) pullData;
- (void) addNewAlbumWithName:(NSString *) albumName;
- (void) setToSelectible;
- (void) setToUnselectible;
- (void) setToUnselectiblePriorToRefresh;
- (void) cancelRequests;

@end

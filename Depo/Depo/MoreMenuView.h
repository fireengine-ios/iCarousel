//
//  MoreMenuView.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "PhotoAlbum.h"

@protocol MoreMenuDelegate <NSObject>
- (void) moreMenuDidSelectSortWithList;
- (void) moreMenuDidSelectFav;
- (void) moreMenuDidSelectUnfav;
- (void) moreMenuDidSelectShare;
- (void) moreMenuDidSelectDelete;
- (void) moreMenuDidSelectVideoDetail;
- (void) moreMenuDidSelectImageDetail;
- (void) moreMenuDidSelectAlbumShare;
- (void) moreMenuDidSelectAlbumDelete;
- (void) moreMenuDidSelectDownloadImage;
- (void) moreMenuDidDismiss;
- (void) moreMenuDidSelectMusicDetail;
- (void) moreMenuDidSelectVideofy;
@end

@interface MoreMenuView : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<MoreMenuDelegate> delegate;
@property (nonatomic, strong) UITableView *moreTable;
@property (nonatomic, strong) NSArray *moreList;
@property (nonatomic, strong) MetaFile *fileFolder;
@property (nonatomic, strong) PhotoAlbum *album;

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef;
- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef withFileFolder:(MetaFile *) _fileFolder;
- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef withFileFolder:(MetaFile *) _fileFolder withAlbum:(PhotoAlbum *) _album;

@end

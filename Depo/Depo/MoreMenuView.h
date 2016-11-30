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

#import "ConfirmDeleteModalController.h"
#import "SortModalController.h"
#import "MoveListModalController.h"
#import "PhotoAlbumListModalController.h"
#import "RecentActivitiesController.h"
#import "FolderDetailModalController.h"
#import "FileDetailModalController.h"
#import "AlbumDetailModalController.h"

@protocol MoreMenuDelegate <NSObject>
- (void) moreMenuDidSelectSortWithList;
- (void) moreMenuDidSelectSort;
- (void) moreMenuDidSelectFav;
- (void) moreMenuDidSelectUnfav;
- (void) moreMenuDidSelectShare;
- (void) moreMenuDidSelectDelete;
- (void) moreMenuDidSelectRemoveFromAlbum;
- (void) moreMenuDidSelectVideoDetail;
- (void) moreMenuDidSelectImageDetail;
- (void) moreMenuDidSelectAlbumShare;
- (void) moreMenuDidSelectAlbumDelete;
- (void) moreMenuDidSelectDownloadImage;
- (void) moreMenuDidSelectDownloadAlbum;
- (void) moreMenuDidDismiss;
- (void) moreMenuDidSelectMusicDetail;
- (void) moreMenuDidSelectVideofy;
- (void) moreMenuDidSelectAlbumDetailForAlbum:(PhotoAlbum *) album;
- (void) moreMenuDidSelectFolderDetailForFolder:(MetaFile *) folder;
- (void) moreMenuDidSelectFileDetailForFile:(MetaFile *) file;
- (void) moreMenuDidSelectUpdateSelectOption;
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


+(void)presentConfirmDeleteFromController:(UIViewController *)controller delegateOwner:(id<ConfirmDeleteDelegate>)delegateOwner;
+(void)presentSortFromController:(UIViewController *)controller delegateOwner:(id<SortModalDelegate>)delegateOwner;
+(void)presnetSortWithList:(NSArray *)sortTypeList
            fromController:(UIViewController *)controller
             delegateOwner:(id<SortModalDelegate>)delegateOwner;
+(void)presentMoveFoldersListFromController:(UIViewController *)controller delegateOwner:(id<MoveListModalProtocol>)delegateOwner;
+(void)presentMoveFoldersListWithExcludingFolder:(NSString *)folderUUID
                                  fromController:(UIViewController *)controller
                                   delegateOwner:(id<MoveListModalProtocol>)delegateOwner;

+(void)presentMoveFoldersListWithExcludingFolder:(NSString *)folderUUID
                            prohibitedFolderList:(NSArray *)prohibitedList
                                  fromController:(UIViewController *)controller
                                   delegateOwner:(id<MoveListModalProtocol>)delegateOwner;

+(void)presentPhotoAlbumsFromController:(UIViewController *)controller delegateOwner:(id<AlbumModalDelete>)delegateOwner;
+(void)presentRecentActivitesFromController:(UIViewController *)controller;
+(void)presentFolderDetailForFolder:(MetaFile *)folder
                    fromController:(UIViewController *)controller
                     delegateOwner:(id<FolderDetailDelegate>)delegateOwner;

+(void)presentFileDetailForFile:(MetaFile *)file
                 fromController:(UIViewController *)controller
                  delegateOwner:(id<FileDetailDelegate>)delegateOwner;

+(void)presentAlbumDetailForAlbum:(PhotoAlbum *)album
                   fromController:(UIViewController *)controller
                    delegateOwner:(id<AlbumDetailDelegate>)delegateOwner;

@end

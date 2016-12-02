//
//  PhotoAlbumController.h
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "PhotoAlbum.h"
#import "AlbumDetailDao.h"
#import "RenameAlbumDao.h"
#import "DeleteAlbumsDao.h"
#import "AlbumRemovePhotosDao.h"
#import "SquareImageView.h"
#import "PhotoAlbumFooterActionsMenuView.h"
//#import "FooterActionsMenuView.h"
#import "ShareLinkDao.h"
#import "AddAlbumDao.h"
#import "ImagePreviewController.h"
#import "CurrentPhotoListModalController.h"
#import "VideoPreviewController.h"

@protocol PhotoAlbumDelegate <NSObject>
- (void) photoAlbumDidChange:(NSString *) albumUuid;
@end

@interface PhotoAlbumController : MyViewController <SquareImageDelegate, PhotoAlbumFooterActionsDelegate, ImagePreviewDelegate, VideoPreviewDelegate, UIScrollViewDelegate, CurrentPhotoListModalDelegate, ConfirmRemoveDelegate> {
    AlbumDetailDao *detailDao;
    RenameAlbumDao *renameDao;
    DeleteAlbumsDao *deleteDao;
    AlbumRemovePhotosDao *deleteImgDao;
    ShareLinkDao *shareDao;
    AlbumAddPhotosDao *albumAddPhotosDao;
    
    UIImageView *emptyBgImgView;
    CustomButton *moreButton;
    CustomButton *cancelButton;
    CustomLabel *titleLabel;
    CustomLabel *subTitleLabel;
    UIView *topBgView;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
    BOOL contentModified;
    
    MyNavigationController *printNav;
}

@property (nonatomic, weak) id<PhotoAlbumDelegate> delegate;
@property (nonatomic, strong) PhotoAlbum *album;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) MoreMenuView *moreMenuView;

@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) NSMutableArray *selectedFileLinkList;
@property (nonatomic, strong) PhotoAlbumFooterActionsMenuView *footerActionMenu;
//@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;
@property (nonatomic, strong) UIRefreshControl *refreshControlPhotos;


- (id)initWithAlbum:(PhotoAlbum *) _album;
- (id)initWithAlbumUUID:(NSString *) _albumUUID;


@end

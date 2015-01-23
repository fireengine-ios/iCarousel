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
#import "FooterActionsMenuView.h"
#import "ShareLinkDao.h"
#import "ImagePreviewController.h"

@interface PhotoAlbumController : MyViewController <SquareImageDelegate, FooterActionsDelegate, ImagePreviewDelegate> {
    AlbumDetailDao *detailDao;
    RenameAlbumDao *renameDao;
    DeleteAlbumsDao *deleteDao;
    AlbumRemovePhotosDao *deleteImgDao;
    ShareLinkDao *shareDao;
    
    UIImageView *emptyBgImgView;
    CustomButton *moreButton;
    CustomButton *cancelButton;
    CustomLabel *titleLabel;
    CustomLabel *subTitleLabel;
    UIView *topBgView;

    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, strong) PhotoAlbum *album;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) MoreMenuView *moreMenuView;

@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) FooterActionsMenuView *footerActionMenu;

- (id)initWithAlbum:(PhotoAlbum *) _album;

@end

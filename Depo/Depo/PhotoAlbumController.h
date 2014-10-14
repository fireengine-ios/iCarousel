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
#import "SquareImageView.h"

@interface PhotoAlbumController : MyViewController <SquareImageDelegate> {
    AlbumDetailDao *detailDao;
    UIImageView *emptyBgImgView;

    int listOffset;
    BOOL isLoading;
}

@property (nonatomic, strong) PhotoAlbum *album;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;

- (id)initWithAlbum:(PhotoAlbum *) _album;

@end

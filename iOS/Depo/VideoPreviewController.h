//
//  VideoPreviewController.h
//  Depo
//
//  Created by Mahir on 10/14/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"
#import "CustomAVPlayer.h"

#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "RenameDao.h"
#import "ShareLinkDao.h"
#import "CoverPhotoDao.h"
#import "CustomConfirmView.h"
#import "ConfirmRemoveModalController.h"
#import "AlbumRemovePhotosDao.h"

@protocol VideoPreviewDelegate <NSObject>
- (void) previewedVideoWasDeleted:(MetaFile *) deletedFile;
@end

@interface VideoPreviewController : MyViewController <CustomAVPlayerDelegate, CustomConfirmDelegate, ConfirmRemoveDelegate> {
    CustomButton *moreButton;
    
    DeleteDao *deleteDao;
    AlbumRemovePhotosDao *removeDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
    ShareLinkDao *shareDao;
    CoverPhotoDao *coverDao;
//    BOOL refFromAlbumFlag;
}

@property (nonatomic, weak) id<VideoPreviewDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) PhotoAlbum *album;
@property (nonatomic, strong) CustomAVPlayer *avPlayer;

- (id)initWithFile:(MetaFile *) _file;
- (id)initWithFile:(MetaFile *) _file withAlbum:(PhotoAlbum*) _album;

@end

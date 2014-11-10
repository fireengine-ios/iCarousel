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

@interface VideoPreviewController : MyViewController <CustomAVPlayerDelegate> {
    CustomButton *moreButton;
    
    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
}

@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) CustomAVPlayer *avPlayer;

- (id)initWithFile:(MetaFile *) _file;

@end

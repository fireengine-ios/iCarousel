//
//  MusicPreviewController.h
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomButton.h"
#import "VolumeLevelIndicator.h"

#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "RenameDao.h"

@interface MusicPreviewController : MyViewController <VolumeLevelDelegate> {
    CustomButton *moreButton;
    
    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
}


@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVURLAsset *currentAsset;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) CustomButton *prevButton;
@property (nonatomic, strong) CustomButton *nextButton;
@property (nonatomic, strong) CustomButton *playButton;
@property (nonatomic, strong) CustomButton *pauseButton;
@property (nonatomic, strong) CustomButton *volumeButton;
@property (nonatomic, strong) UIView *playControlView;
@property (nonatomic, strong) UIView *customVolumeView;
@property (nonatomic, strong) UILabel *totalDuration;
@property (nonatomic, strong) UILabel *passedDuration;
@property (nonatomic, strong) NSMutableArray *volumeLevels;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic) int totalTimeInSec;
@property (nonatomic) int yIndex;
@property (assign) BOOL seekToZeroBeforePlay;

- (id)initWithFile:(MetaFile *) _file;

@end

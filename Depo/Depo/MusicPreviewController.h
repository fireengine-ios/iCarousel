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
#import "CustomLabel.h"
#import "VolumeSliderView.h"

#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "RenameDao.h"
#import "ShareLinkDao.h"

@protocol MusicPreviewDelegate <NSObject>
- (void) previewedMusicWasDeleted;
@end

@interface MusicPreviewController : MyViewController <VolumeSliderDelegate,FileDetailDelegate> {
    CustomButton *moreButton;
    CustomLabel *titleLabel;
    CustomLabel *detailLabel;
    
    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
    ShareLinkDao *shareDao;
    
    int currentItemPlace;
}


@property (nonatomic, strong) id<MusicPreviewDelegate> delegate;
@property (nonatomic, strong) NSString *fileUuid;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) CustomButton *prevButton;
@property (nonatomic, strong) CustomButton *nextButton;
@property (nonatomic, strong) CustomButton *playButton;
@property (nonatomic, strong) CustomButton *pauseButton;
@property (nonatomic, strong) CustomButton *volumeButton;
@property (nonatomic, strong) CustomButton *shuffleButton;
@property (nonatomic, strong) UIView *playControlView;
@property (nonatomic, strong) VolumeSliderView *customVolumeView;
@property (nonatomic, strong) UILabel *totalDuration;
@property (nonatomic, strong) UILabel *passedDuration;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic) int totalTimeInSec;
@property (nonatomic) int yIndex;
@property (assign) BOOL seekToZeroBeforePlay;

- (id)initWithFile:(NSString *) _fileUuid withFileList:(NSArray *) _files;
- (id)initForContinuingPlaylist;

@end

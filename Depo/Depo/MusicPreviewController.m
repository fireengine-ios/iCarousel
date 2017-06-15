//
//  MusicPreviewController.m
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicPreviewController.h"
#import "Util.h"
#import "VolumeLevelIndicator.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AudioManager.h"
#import "ShareActivity.h"

static void *AVPlayerPlaybackViewControllerRateObservationContext = &AVPlayerPlaybackViewControllerRateObservationContext;
static void *AVPlayerPlaybackViewControllerStatusObservationContext = &AVPlayerPlaybackViewControllerStatusObservationContext;
static void *AVPlayerPlaybackViewControllerCurrentItemObservationContext = &AVPlayerPlaybackViewControllerCurrentItemObservationContext;

@interface MusicPreviewController ()

@end

@implementation MusicPreviewController

@synthesize delegate;
@synthesize fileUuid;
@synthesize files;
@synthesize prevButton;
@synthesize nextButton;
@synthesize playButton;
@synthesize pauseButton;
@synthesize volumeButton;
@synthesize playControlView;
@synthesize customVolumeView;
@synthesize totalDuration;
@synthesize passedDuration;
@synthesize slider;
@synthesize totalTimeInSec;
@synthesize controlView;
@synthesize yIndex;
@synthesize seekToZeroBeforePlay;
@synthesize shuffleButton;

- (id)initWithFile:(NSString *) _fileUuid withFileList:(NSArray *) _files {
    self = [super init];
    if (self) {
        self.fileUuid = _fileUuid;
        self.files = _files;
        self.view.backgroundColor = [UIColor blackColor];
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        favDao = [[FavoriteDao alloc] init];
        favDao.delegate = self;
        favDao.successMethod = @selector(favSuccessCallback:);
        favDao.failMethod = @selector(favFailCallback:);
        
        renameDao = [[RenameDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);

        UIImage *albumImg = [UIImage imageNamed:@"no_music_icon.png"];
        UIImageView *albumImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - albumImg.size.width)/2, 60, albumImg.size.width, albumImg.size.height)];
        albumImgView.image = albumImg;
        [self.view addSubview:albumImgView];
        
        MetaFile *file = [self currentFile];
        NSString *nameVal = file.visibleName;
        if(file.detail && file.detail.songTitle) {
            nameVal = file.detail.songTitle;
        }

        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, albumImgView.frame.origin.y + albumImgView.frame.size.height + 50, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor] withText:nameVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];

        NSString *detailVal = @"";
        if(file.detail && file.detail.artist) {
            detailVal = file.detail.artist;
        }
        if(file.detail && file.detail.album) {
            detailVal = [NSString stringWithFormat:@"%@ • %@", detailVal, file.detail.album];
        }
        
        detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:detailVal];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:detailLabel];

        yIndex = detailLabel.frame.origin.y + detailLabel.frame.size.height + (IS_IPHONE_5 ? 90 : 14);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNotified) name:MUSIC_RESUMED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotified) name:MUSIC_PAUSED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingMusicChanged:) name:MUSIC_CHANGED_NOTIFICATION object:nil];

        [self initializePlayer];
    }
    return self;
}

- (id)initForContinuingPlaylist {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        favDao = [[FavoriteDao alloc] init];
        favDao.delegate = self;
        favDao.successMethod = @selector(favSuccessCallback:);
        favDao.failMethod = @selector(favFailCallback:);
        
        renameDao = [[RenameDao alloc] init];
        renameDao.delegate = self;
        renameDao.successMethod = @selector(renameSuccessCallback:);
        renameDao.failMethod = @selector(renameFailCallback:);
        
        UIImage *albumImg = [UIImage imageNamed:@"no_music_icon.png"];
        UIImageView *albumImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - albumImg.size.width)/2, 60, albumImg.size.width, albumImg.size.height)];
        albumImgView.image = albumImg;
        [self.view addSubview:albumImgView];
        
        MetaFile *file = [APPDELEGATE.session itemRefForCurrentAsset];
        self.fileUuid = file.uuid;
        NSString *nameVal = file.visibleName;
        if(file.detail && file.detail.songTitle) {
            nameVal = file.detail.songTitle;
        }
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, albumImgView.frame.origin.y + albumImgView.frame.size.height + 50, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor] withText:nameVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];
        
        NSString *detailVal = @"";
        if(file.detail && file.detail.artist) {
            detailVal = file.detail.artist;
        }
        if(file.detail && file.detail.album) {
            detailVal = [NSString stringWithFormat:@"%@ • %@", detailVal, file.detail.album];
        }
        
        detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:detailVal];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:detailLabel];
        
        yIndex = detailLabel.frame.origin.y + detailLabel.frame.size.height + (IS_IPHONE_5 ? 90 : 14);
        
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        self.navigationItem.leftBarButtonItem = backButton;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNotified) name:MUSIC_RESUMED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotified) name:MUSIC_PAUSED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingMusicChanged:) name:MUSIC_CHANGED_NOTIFICATION object:nil];
        
        [self initializeOngoingPlayer];
    }
    return self;
}

- (void) initializePlayer {
    [APPDELEGATE initAudioSession];

    [self initializeControls];

    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    currentItemPlace = 0;
    for(int i=0; i< [self.files count]; i++) {
        MetaFile *row = [self.files objectAtIndex:i];
        AVPlayerItem *rowPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:row.tempDownloadUrl]];
        [items addObject:rowPlayerItem];
        
        if([row.uuid isEqualToString:self.fileUuid]) {
            currentItemPlace = i;
        }
    }

    self.title = [NSString stringWithFormat:@"%d/%d", currentItemPlace + 1, (int)[items count]];
    APPDELEGATE.session.playerItems = items;
    APPDELEGATE.session.playerItemFilesRef = self.files;
    //[APPDELEGATE.session.audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    [APPDELEGATE.session playAudioItemAtIndex:currentItemPlace];

    __weak MusicPreviewController *weakSelf = self;
    [APPDELEGATE.session.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:NULL usingBlock:^(CMTime time) {
        [weakSelf syncSlider];
        [weakSelf initNowPlayingInfoCenter:[weakSelf currentFile]];
    }];
    
    float currentVolumeVal = [APPDELEGATE.session.audioPlayer volume];
    [customVolumeView setInitialVolumeLevels:currentVolumeVal];
    
    playButton.hidden = YES;
    pauseButton.hidden = NO;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    APPDELEGATE.session.audioPlayer = (AVPlayer *) object;
    if ([keyPath isEqualToString:@"status"]) {
        if (APPDELEGATE.session.audioPlayer.status == AVPlayerStatusReadyToPlay) {
            [APPDELEGATE.session.audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
            if (APPDELEGATE.session.playerItem.status == AVPlayerStatusReadyToPlay) {
                [APPDELEGATE.session.audioPlayer play];
            }
        } else if (APPDELEGATE.session.audioPlayer.status == AVPlayerStatusFailed) {
            
        }
        else if(APPDELEGATE.session.audioPlayer.status == AVPlayerItemStatusUnknown) {
            [self initializePlayer];
        }
    }
}

- (void) initializeOngoingPlayer {
    [self initializeControls];
    
    self.title = [NSString stringWithFormat:@"%d/%d", APPDELEGATE.session.currentAudioItemIndex + 1, (int)[APPDELEGATE.session.playerItems count]];
    
    __weak MusicPreviewController *weakSelf = self;
    [APPDELEGATE.session.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:NULL usingBlock:^(CMTime time) {
        [weakSelf syncSlider];
    }];
    
    float currentVolumeVal = [APPDELEGATE.session.audioPlayer volume];
    [customVolumeView setInitialVolumeLevels:currentVolumeVal];
    
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    
}

- (void) initializeControls {
    controlView = [[UIView alloc] initWithFrame:CGRectMake(10, yIndex, self.view.frame.size.width-20, 120)];
    controlView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:controlView];
    
    passedDuration = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 30, 20)];
    passedDuration.backgroundColor = [UIColor clearColor];
    passedDuration.textColor = [Util UIColorForHexColor:@"9A9A9A"];
    passedDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:13];
    passedDuration.adjustsFontSizeToFitWidth = YES;
    passedDuration.text = @"00:00";
    [controlView addSubview:passedDuration];
    
    totalDuration = [[UILabel alloc] initWithFrame:CGRectMake(controlView.frame.size.width-40, 15, 30, 20)];
    totalDuration.backgroundColor = [UIColor clearColor];
    totalDuration.textColor = [Util UIColorForHexColor:@"9A9A9A"];
    totalDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:13];
    totalDuration.adjustsFontSizeToFitWidth = YES;
    totalDuration.text = @"00:00";//totalDur;
    [controlView addSubview:totalDuration];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 15, controlView.frame.size.width - 100, 20)];
    [slider setThumbImage:[UIImage imageNamed:@"bttn-player-handle.png"] forState:UIControlStateNormal];
    UIImage *sliderMax = [UIImage imageNamed:@"player_track.png"];
    sliderMax=[sliderMax resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch];
    UIImage *sliderMin = [UIImage imageNamed:@"player_progress.png"];
    sliderMin=[sliderMin resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch] ;
    [slider setMinimumTrackImage:sliderMin forState:UIControlStateNormal];
    [slider setMaximumTrackImage:sliderMax forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [controlView addSubview:slider];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 50, controlView.frame.size.width, 1)];
    separator.backgroundColor = [Util UIColorForHexColor:@"1e1e1e"];
    [controlView addSubview:separator];
    
    playControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, controlView.frame.size.width, controlView.frame.size.height - 51)];
    [controlView addSubview:playControlView];
    
    volumeButton = [[CustomButton alloc] initWithFrame:CGRectMake(3, 15, 30, 30) withImageName:@"volume_button.png"];
    volumeButton.hidden = NO;
    [volumeButton addTarget:self action:@selector(volumeClicked) forControlEvents:UIControlEventTouchUpInside];
    volumeButton.isAccessibilityElement = YES;
    volumeButton.accessibilityIdentifier = @"volumeButtonMusicPreview";
    [playControlView addSubview:volumeButton];
    
    prevButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width/2 - 60, 18, 18, 23) withImageName:@"music_prev.png"];
    [prevButton addTarget:self action:@selector(prevClicked) forControlEvents:UIControlEventTouchUpInside];
    prevButton.isAccessibilityElement = YES;
    prevButton.accessibilityIdentifier = @"prevButtonMusicPreview";
    [playControlView addSubview:prevButton];

    nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width/2 + 42, 18, 18, 23) withImageName:@"music_next.png"];
    [nextButton addTarget:self action:@selector(nextClicked) forControlEvents:UIControlEventTouchUpInside];
    nextButton.isAccessibilityElement = YES;
    nextButton.accessibilityIdentifier = @"nextButtonMusicPreview";
    [playControlView addSubview:nextButton];

    playButton = [[CustomButton alloc] initWithFrame:CGRectMake((controlView.frame.size.width - 32)/2, 9, 32, 42) withImageName:@"music_play_icon.png"];
    playButton.hidden = NO;
    [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
    playButton.isAccessibilityElement = YES;
    playButton.accessibilityIdentifier = @"playButtonMusicPreview";
    [playControlView addSubview:playButton];
    
    pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake((controlView.frame.size.width - 32)/2, 4, 32, 52) withImageName:@"pause_icon.png"];
    pauseButton.hidden = YES;
    [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
    pauseButton.isAccessibilityElement = YES;
    pauseButton.accessibilityIdentifier = @"pauseButtonMusicPreview";
    [playControlView addSubview:pauseButton];
    
    shuffleButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width - 40, 10, 40, 40) withImageName:@"shuffle.png"];
    [shuffleButton addTarget:self action:@selector(setShuffleOn) forControlEvents:UIControlEventTouchUpInside];
    shuffleButton.alpha = 0.5f;
    shuffleButton.isAccessibilityElement = YES;
    shuffleButton.accessibilityIdentifier = @"shuffleButtonMusicPreview";
    [playControlView addSubview:shuffleButton];
    
    customVolumeView = [[VolumeSliderView alloc] initWithFrame:CGRectMake(0, 51, controlView.frame.size.width, controlView.frame.size.height - 51)];
    customVolumeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];
    customVolumeView.hidden = YES;
    customVolumeView.delegate = self;
    customVolumeView.isAccessibilityElement = YES;
    customVolumeView.accessibilityIdentifier = @"VolumeSliderMusicPreview";
    [controlView addSubview:customVolumeView];
}

- (void) initNowPlayingInfoCenter:(MetaFile *) songInfo {
    [APPDELEGATE.session initNowPlayingInfoCenter:songInfo];
}

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    [APPDELEGATE.base checkAndShowAddButton];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MUSIC_RESUMED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MUSIC_PAUSED_NOTIFICATION object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) videoDidStart {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
}

- (void) videoDidStop {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
}

- (void) playClicked {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    [APPDELEGATE.session playAudioItem];
}

- (void) pauseClicked {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    [APPDELEGATE.session pauseAudioItem];
}

- (void) shuffleClicked {
    [APPDELEGATE.session shuffleItems];
    self.title = [NSString stringWithFormat:@"%d/%d", APPDELEGATE.session.currentAudioItemIndex + 1, (int)[APPDELEGATE.session.playerItemFilesRef count]];
}

- (void) setShuffleOn {
    APPDELEGATE.session.shuffleFlag = YES;
    shuffleButton.alpha = 1.0f;
    [shuffleButton removeTarget:self action:@selector(setShuffleOn) forControlEvents:UIControlEventTouchUpInside];
    [shuffleButton addTarget:self action:@selector(setShuffleOff) forControlEvents:UIControlEventTouchUpInside];
}

- (void) setShuffleOff {
    APPDELEGATE.session.shuffleFlag = NO;
    shuffleButton.alpha = 0.5f;
    [shuffleButton removeTarget:self action:@selector(setShuffleOff) forControlEvents:UIControlEventTouchUpInside];
    [shuffleButton addTarget:self action:@selector(setShuffleOn) forControlEvents:UIControlEventTouchUpInside];
}

- (void) resumeNotified {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
}

- (void) pauseNotified {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
}

- (void) playingMusicChanged:(NSNotification *) notification {
    
    NSDictionary *userInfo = notification.userInfo;
    MetaFile *musicFilePlaying = [userInfo objectForKey:CHANGED_MUSIC_OBJ_KEY];
    self.fileUuid = musicFilePlaying.uuid;
    NSString *nameVal = musicFilePlaying.visibleName;
    if(musicFilePlaying.detail && musicFilePlaying.detail.songTitle) {
        nameVal = musicFilePlaying.detail.songTitle;
    }
    titleLabel.text = nameVal;

    NSString *detailVal = @"";
    if(musicFilePlaying.detail && musicFilePlaying.detail.artist) {
        detailVal = musicFilePlaying.detail.artist;
    }
    if(musicFilePlaying.detail && musicFilePlaying.detail.album) {
        detailVal = [NSString stringWithFormat:@"%@ • %@", detailVal, musicFilePlaying.detail.album];
    }
    detailLabel.text = detailVal;

    self.title = [NSString stringWithFormat:@"%d/%d", APPDELEGATE.session.currentAudioItemIndex + 1, (int)[APPDELEGATE.session.playerItemFilesRef count]];
    //[self initNowPlayingInfoCenter:musicFilePlaying];
}

- (void) volumeClicked {
    playControlView.hidden = YES;
    customVolumeView.hidden = NO;
    [controlView bringSubviewToFront:customVolumeView];
    [self performSelector:@selector(hideVolumeView) withObject:nil afterDelay:4.0f];
}

- (void) prevClicked {
    if([APPDELEGATE.session isPrevNextAvailable]) {
        if(APPDELEGATE.session.shuffleFlag) {
            [APPDELEGATE.session playPreviousShuffleAudioItem];
        } else {
            [APPDELEGATE.session playPreviousAudioItem];
        }
    }
}

- (void) nextClicked {
    if([APPDELEGATE.session isPrevNextAvailable]) {
        if(APPDELEGATE.session.shuffleFlag) {
            [APPDELEGATE.session playNextShuffledAudioItem];
        } else {
            [APPDELEGATE.session playNextAudioItem];
        }
    }
}

- (void) hideVolumeView {
    customVolumeView.hidden = YES;
    playControlView.hidden = NO;
}

- (void) volumeSliderDidSelectMute {
    [self changeVolumeTo:0.0f];
}

- (void) volumeSliderDidSelectMax {
    [self changeVolumeTo:1.0f];
}

- (void) volumeSliderDidChangeTo:(float)newVolumeVal {
    [self changeVolumeTo:newVolumeVal];
}

- (void) updateTime:(int) time withTotalDuration:(int) totalDur {
    passedDuration.text = [self formatPlayTime:time];
    totalDuration.text = [self formatPlayTime:totalDur];
    if(totalDur > 0) {
        self.totalTimeInSec = totalDur;
        [self updateSlider:time withTotalDuration:totalDur];
    }
}

- (void) updateSlider:(int) time withTotalDuration:(int) totalDur {
    float minValue = [slider minimumValue];
    float maxValue = [slider maximumValue];
    [slider setValue:(maxValue - minValue) * time / totalDur + minValue];
}

- (NSString *) formatPlayTime:(int)second{
    if(second < 0){
        return @"--:--";
    } else {
        return [NSString stringWithFormat:@"%02d:%02d",(int)(second/60),(int)(second%60)];
    }
}

- (void) sliderChanged:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *aSlider = sender;
        
        if (isfinite(totalTimeInSec)) {
            float minValue = [aSlider minimumValue];
            float maxValue = [aSlider maximumValue];
            float value = [aSlider value];
            double time = totalTimeInSec * (value - minValue) / (maxValue - minValue);
            [self triggerSeek:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

- (void) triggerSeek:(CMTime)timeToSeek {
    [APPDELEGATE.session.audioPlayer seekToTime:timeToSeek];
}

- (void) changeVolumeTo:(float)volumeVal {
    if(APPDELEGATE.session.playerItem) {
        NSArray *audioTracks = [APPDELEGATE.session.playerItem tracks];
        
        NSMutableArray *allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks) {
            AVMutableAudioMixInputParameters *audioInputParams =
            [AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:volumeVal atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        [APPDELEGATE.session.playerItem setAudioMix:audioMix];
    }
}

- (void) syncSlider {
    CMTime playerDuration = [self readItemDuration];
    CMTime playerTime = [self readCurrentTime];
    
    if (CMTIME_IS_INVALID(playerDuration)) {
        [self updateTime:-1 withTotalDuration:-1];
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    double time = CMTimeGetSeconds(playerTime);
    if (isfinite(duration)) {
        [self updateTime:time withTotalDuration:duration];
    }
}

- (CMTime) readItemDuration {
    if (APPDELEGATE.session.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return([APPDELEGATE.session.playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

- (CMTime) readCurrentTime {
    return [APPDELEGATE.session.playerItem currentTime];
}

/*
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (context == AVPlayerPlaybackViewControllerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown: {
            }
                break;
                
            case AVPlayerStatusReadyToPlay: {
                [self.player play];
                [self videoDidStart];
                
                float currentVolumeVal = [self.player volume];
                [self initialVolumeLevel:currentVolumeVal];
                
                __weak MusicPreviewController *weakSelf = self;
                [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:NULL usingBlock:^(CMTime time) {
                    [weakSelf syncSlider];
                }];
            }
                break;
                
            case AVPlayerStatusFailed: {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    } else if (context == AVPlayerPlaybackViewControllerRateObservationContext) {
    } else if (context == AVPlayerPlaybackViewControllerCurrentItemObservationContext) {
    } else {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}
*/

- (MetaFile *) currentFile {
    for(MetaFile *row in self.files) {
        if([row.uuid isEqualToString:self.fileUuid]) {
            return row;
        }
    }
    return nil;
}

- (void) moreClicked {
    MetaFile *file = [APPDELEGATE.session itemRefForCurrentAsset];
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeMusicDetail], [NSNumber numberWithInt:MoreMenuTypeShare], file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDelete]] withFileFolder:file];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [APPDELEGATE.session stopAudioItem];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    [delegate previewedMusicWasDeleted];
    [self.nav popViewControllerAnimated:YES];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    MetaFile *file = [APPDELEGATE.session itemRefForCurrentAsset];
    file.detail.favoriteFlag = [favFlag boolValue];
    [self proceedSuccessForProgressView];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(MetaFile *) updatedFileRef {
    [self proceedSuccessForProgressView];

    MetaFile *file = [APPDELEGATE.session itemRefForCurrentAsset];
    file.name = updatedFileRef.name;
    file.visibleName = updatedFileRef.name;
    file.lastModified = updatedFileRef.lastModified;
//    self.title = file.visibleName;
}

- (void) renameFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) fileDetailShouldRename:(NSString *)newNameVal {
    [renameDao requestRenameForFile:self.fileUuid withNewName:newNameVal];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RenameFileProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RenameFileSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RenameFileFailMessage", @"")];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectMusicDetail {
    [MoreMenuView presentFileDetailForFile:[self currentFile] fromController:self.nav delegateOwner:self];
}


- (void) moreMenuDidSelectDelete {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmDeleteDidConfirm];
    } else {
        ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
        confirmDelete.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
}



- (void) moreMenuDidSelectFav {
    [favDao requestMetadataForFiles:@[self.fileUuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) moreMenuDidSelectUnfav {
    [favDao requestMetadataForFiles:@[self.fileUuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) moreMenuDidSelectShare {
    //[APPDELEGATE.base triggerShareForFiles:@[self.fileUuid]];
    [shareDao requestLinkForFiles:@[self.fileUuid]];
    [self showLoading];
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    [deleteDao requestDeleteFiles:@[self.fileUuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

#pragma mark ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self hideLoading];
    NSArray *activityItems = [NSArray arrayWithObjects:
                              [NSURL URLWithString:linkToShare], nil];
    
    ShareActivity *activity = [[ShareActivity alloc] init];
    activity.sourceViewController = self;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:@[activity]];
    
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
    
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(IS_IPAD ? (self.view.frame.size.width - 240)/2 : self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IGLog(@"MusicPreviewController viewDidLoad");

    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) cancelRequests {
    [deleteDao cancelRequest];
    deleteDao = nil;
    
    [favDao cancelRequest];
    favDao = nil;
    
    [renameDao cancelRequest];
    renameDao = nil;
    
    [shareDao cancelRequest];
    shareDao = nil;
}

@end

//
//  MusicPreviewController.m
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicPreviewController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "VolumeLevelIndicator.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

static void *AVPlayerPlaybackViewControllerRateObservationContext = &AVPlayerPlaybackViewControllerRateObservationContext;
static void *AVPlayerPlaybackViewControllerStatusObservationContext = &AVPlayerPlaybackViewControllerStatusObservationContext;
static void *AVPlayerPlaybackViewControllerCurrentItemObservationContext = &AVPlayerPlaybackViewControllerCurrentItemObservationContext;

@interface MusicPreviewController ()

@end

@implementation MusicPreviewController

@synthesize file;
@synthesize player;
@synthesize mPlayerItem;
@synthesize playerLayer;
@synthesize currentAsset;
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
@synthesize volumeLevels;
@synthesize controlView;
@synthesize yIndex;
@synthesize seekToZeroBeforePlay;

- (id)initWithFile:(MetaFile *) _file {
    self = [super init];
    if (self) {
        self.file = _file;
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

        volumeLevels = [[NSMutableArray alloc] init];

        UIImage *albumImg = [UIImage imageNamed:@"no_music_icon.png"];
        UIImageView *albumImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - albumImg.size.width)/2, 60, albumImg.size.width, albumImg.size.height)];
        albumImgView.image = albumImg;
        [self.view addSubview:albumImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, albumImgView.frame.origin.y + albumImgView.frame.size.height + 50, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor] withText:self.file.name];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];

        yIndex = titleLabel.frame.origin.y + titleLabel.frame.size.height + (IS_IPHONE_5 ? 70 : 30);
    }
    return self;
}

- (void) initializePlayer {
    self.currentAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.file.tempDownloadUrl] options:nil];

    NSArray *requestedKeys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];
    
    [currentAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            [self prepareToPlayAsset:currentAsset withKeys:requestedKeys];
                            [self initializeControls];
                        });
     }];

//    self.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.file.tempDownloadUrl]];
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
    
    volumeButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 22, 16, 16) withImageName:@"volume_button.png"];
    volumeButton.hidden = NO;
    [volumeButton addTarget:self action:@selector(volumeClicked) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:volumeButton];
    
    prevButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width/2 - 60, 21, 26, 18) withImageName:@"music_backward.png"];
    [playControlView addSubview:prevButton];

    nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width/2 + 34, 21, 26, 18) withImageName:@"music_forward.png"];
    [playControlView addSubview:nextButton];

    playButton = [[CustomButton alloc] initWithFrame:CGRectMake((controlView.frame.size.width - 32)/2, 9, 32, 42) withImageName:@"music_play_icon.png"];
    playButton.hidden = NO;
    [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:playButton];
    
    pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake((controlView.frame.size.width - 32)/2, 4, 32, 52) withImageName:@"pause_icon.png"];
    pauseButton.hidden = YES;
    [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:pauseButton];
    
    customVolumeView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, controlView.frame.size.width, controlView.frame.size.height - 51)];
    customVolumeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];
    customVolumeView.hidden = YES;
    [controlView addSubview:customVolumeView];
    
    CustomButton *volumeMuteButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 22, 19, 16) withImageName:@"volume_mute.png"];
    [volumeMuteButton addTarget:self action:@selector(volumeMuteClicked) forControlEvents:UIControlEventTouchUpInside];
    [customVolumeView addSubview:volumeMuteButton];
    
    CustomButton *volumeFullButton = [[CustomButton alloc] initWithFrame:CGRectMake(controlView.frame.size.width - 29, 22, 19, 16) withImageName:@"volume_full.png"];
    [volumeFullButton addTarget:self action:@selector(volumeFullClicked) forControlEvents:UIControlEventTouchUpInside];
    [customVolumeView addSubview:volumeFullButton];
    
    for(int i=0; i<23; i++) {
        VolumeLevelIndicator *volIndicator = [[VolumeLevelIndicator alloc] initWithFrame:CGRectMake(50 + (i-1)*10, 26, 8, 8) withLevel:(i+1)];
        volIndicator.delegate = self;
        [customVolumeView addSubview:volIndicator];
        
        [volumeLevels addObject:volIndicator];
    }
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    for (NSString *thisKey in requestedKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable) {
        NSString *localizedDescription = @"Şarkı oynatılamıyor.";
        NSString *localizedFailureReason = @"Şarkı oynatılabilir formatta değil.";
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        return;
    }
    
    if (self.mPlayerItem) {
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    }
    
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerStatusObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
    
    self.seekToZeroBeforePlay = NO;
    
    if (!player) {
        self.player = [AVPlayer playerWithPlayerItem:self.mPlayerItem];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view.layer addSublayer:playerLayer];
        
        [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerCurrentItemObservationContext];
        
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerRateObservationContext];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.mPlayerItem];
    }
    
    if (self.player.currentItem != self.mPlayerItem) {
        [self.player replaceCurrentItemWithPlayerItem:self.mPlayerItem];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"191e24"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if(player) {
        [playerLayer.player pause];
        [playerLayer removeFromSuperlayer];
        player = nil;
    }
    
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"3fb0e8"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void) initialVolumeLevel:(float) level {
    int currentLevel = floor(level / 0.04f);
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= currentLevel) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
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
    if(player) {
        [player play];
    }
}

- (void) pauseClicked {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    if(player) {
        [player pause];
    }
}

- (void) volumeClicked {
    playControlView.hidden = YES;
    customVolumeView.hidden = NO;
    [controlView bringSubviewToFront:customVolumeView];
    [self performSelector:@selector(hideVolumeView) withObject:nil afterDelay:4.0f];
}

- (void) hideVolumeView {
    customVolumeView.hidden = YES;
    playControlView.hidden = NO;
}

- (void) volumeFullClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyActivate];
    }
    [self changeVolumeTo:1.0f];
}

- (void) volumeMuteClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyDeactivate];
    }
    [self changeVolumeTo:0.0f];
}

- (void) volumeLevelIndicatorWasSelected:(int)levelSelected {
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= levelSelected) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
    [self changeVolumeTo:0.04*levelSelected];
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
//    [player seekToTime:timeToSeek];
}

- (void) changeVolumeTo:(float)volumeVal {
    if(player) {
        NSArray *audioTracks = [currentAsset tracksWithMediaType:AVMediaTypeAudio];
        
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
        
        [mPlayerItem setAudioMix:audioMix];
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
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

- (CMTime) readCurrentTime {
    return [self.player currentTime];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    self.seekToZeroBeforePlay = YES;
    [self.player seekToTime:kCMTimeZero];
    [self videoDidStop];
}

- (void)assetFailedToPrepareForPlayback:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Şarkı Oynatılamadı" message:@"Bu şarkı oynatılamıyor. Lütfen başka bir şarkı deneyin." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
    [alertView show];
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (context == AVPlayerPlaybackViewControllerStatusObservationContext) {
        //		[self syncPlayPauseButtons];
        
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

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeFileDetail], [NSNumber numberWithInt:MoreMenuTypeShare], self.file.detail.favoriteFlag ? [NSNumber numberWithInt:MoreMenuTypeUnfav] : [NSNumber numberWithInt:MoreMenuTypeFav], [NSNumber numberWithInt:MoreMenuTypeDelete]] withFileFolder:self.file];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self performSelector:@selector(postDelete) withObject:nil afterDelay:1.0f];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) postDelete {
    [self.nav popViewControllerAnimated:YES];
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    self.file.detail.favoriteFlag = [favFlag boolValue];
    [self proceedSuccessForProgressView];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) renameSuccessCallback:(MetaFile *) updatedFileRef {
    [self proceedSuccessForProgressView];
    self.file.visibleName = updatedFileRef.name;
    self.file.lastModified = updatedFileRef.lastModified;
    self.title = self.file.visibleName;
}

- (void) renameFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) fileDetailShouldRename:(NSString *)newNameVal {
    [renameDao requestRenameForFile:self.file.uuid withNewName:newNameVal];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"RenameFileProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"RenameFileSuccessMessage", @"") andFailMessage:NSLocalizedString(@"RenameFileFailMessage", @"")];
}

#pragma mark MoreMenuDelegate

- (void) moreMenuDidSelectDelete {
    [APPDELEGATE.base showConfirmDelete];
}

- (void) moreMenuDidSelectFav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) moreMenuDidSelectUnfav {
    [favDao requestMetadataForFiles:@[self.file.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) moreMenuDidSelectShare {
    NSLog(@"At INNER moreMenuDidSelectShare");
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
    NSLog(@"At INNER confirmDeleteDidCancel");
}

- (void) confirmDeleteDidConfirm {
    [deleteDao requestDeleteFiles:@[self.file.uuid]];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initializePlayer];
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

@end

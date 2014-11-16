//
//  CustomAVPlayer.m
//
//  Created by Mahir on 4/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "CustomAVPlayer.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

static void *AVPlayerPlaybackViewControllerRateObservationContext = &AVPlayerPlaybackViewControllerRateObservationContext;
static void *AVPlayerPlaybackViewControllerStatusObservationContext = &AVPlayerPlaybackViewControllerStatusObservationContext;
static void *AVPlayerPlaybackViewControllerCurrentItemObservationContext = &AVPlayerPlaybackViewControllerCurrentItemObservationContext;

static void *VLAirplayButtonObservationContext = &VLAirplayButtonObservationContext;

@implementation CustomAVPlayer

@synthesize delegate;
@synthesize mPlayerItem;
@synthesize player;
@synthesize playerLayer;
@synthesize currentAsset;
@synthesize seekToZeroBeforePlay;
@synthesize controlVisible;
@synthesize video;
@synthesize controlView;
@synthesize initialRect;
@synthesize maxRect;
@synthesize maxLandscapeRect;
@synthesize lastContact;

- (id)initWithFrame:(CGRect)frame withVideo:(MetaFile *) _video {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.video = _video;
        self.initialRect = frame;
        self.maxRect = CGRectMake(frame.origin.x, frame.origin.y, APPDELEGATE.window.frame.size.width-frame.origin.x, APPDELEGATE.window.frame.size.height-frame.origin.y);
        self.clipsToBounds = YES;
        self.maxLandscapeRect = CGRectMake(frame.origin.x, frame.origin.y, APPDELEGATE.window.frame.size.height-frame.origin.x, APPDELEGATE.window.frame.size.width-frame.origin.y);

    }
    return self;
}

- (void) initializePlayer {
    self.currentAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.video.tempDownloadUrl] options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [currentAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:currentAsset withKeys:requestedKeys];
                            [self initializeControlAndInfo];
                        });
     }];
}

- (void) initializeControlAndInfo {
    if(controlView) {
        [controlView removeFromSuperview];
    }
    
    controlView = [[CustomAVControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-110, self.frame.size.width, 110) withTotalDuration:self.video.contentLengthDisplay];
    //        controlView.alpha = 0.8;
    controlView.delegate = self;
    controlVisible = YES;
    [self addSubview:controlView];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
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
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable) {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = @"Video oynatılamıyor.";
		NSString *localizedFailureReason = @"Video oynatılabilir formatta değil.";
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
	/* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem) {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerStatusObservationContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
	
    self.seekToZeroBeforePlay = NO;
	
    if (!player) {
        self.player = [AVPlayer playerWithPlayerItem:self.mPlayerItem];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:playerLayer];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVPlayerPlaybackViewControllerRateObservationContext];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.mPlayerItem];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem) {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [self.player replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        //        [self syncPlayPauseButtons];
    }
	
    //    [self.mScrubber setValue:0.0];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Video Oynatılamadı" message:@"Bu Video içeriği oynatılamıyor. Lütfen başka bir Video içeriği deneyin." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
	[alertView show];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	self.seekToZeroBeforePlay = YES;
    [self.player seekToTime:kCMTimeZero];
    [self.controlView videoDidStop];
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
                [self.controlView videoDidStart];
                
                float currentVolumeVal = [self.player volume];
                [self.controlView initialVolumeLevel:currentVolumeVal];
                
                UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
                [panRecognizer setMinimumNumberOfTouches:1];
                [panRecognizer setMaximumNumberOfTouches:1];
                [self addGestureRecognizer:panRecognizer];

                __weak CustomAVPlayer *weakSelf = self;
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
	} else if(context==VLAirplayButtonObservationContext){
    } else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

- (void) videoTapped {
    float newAlpha = 0.0f;
    if(controlVisible) {
        controlVisible = NO;
        newAlpha = 0.0f;
    } else {
        controlVisible = YES;
        newAlpha = 1.0f;
    }
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    controlView.alpha = newAlpha;
	[UIView commitAnimations];
}

- (void) customAVShouldPause {
    [self.player pause];
}

- (void) customAVShouldPlay {
    [self.player play];
}

- (void) customAVShouldBeFullScreen {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if((IS_IPAD && CGRectEqualToRect(self.frame, maxLandscapeRect)) ||
        (!IS_IPAD && CGRectEqualToRect(self.frame, maxRect))) {
        [self updateFrame:initialRect isMax:NO];
        [delegate customPlayerDidScrollInitialScreen];
    } else {
        if(IS_IPAD) {
            [self updateFrame:maxLandscapeRect isMax:YES];
        } else {
            [self updateFrame:maxRect isMax:YES];
        }
        [delegate customPlayerDidScrollFullScreen];
    }
    [UIView commitAnimations];
}

- (void) customAVShouldSeek:(CMTime)timeToSeek {
    [self.player seekToTime:timeToSeek];
}

- (void) customAVShouldChangeVolumeTo:(float)volumeVal {
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
        [controlView updateTime:-1 withTotalDuration:-1];
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	double time = CMTimeGetSeconds(playerTime);
	if (isfinite(duration)) {
        [controlView updateTime:time withTotalDuration:duration];
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

- (void) move:(id)sender {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(!IS_IPAD && !UIDeviceOrientationIsPortrait(orientation))
        return;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastContact = translatedPoint;
    } else {
        CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + (translatedPoint.y - lastContact.y));
        if(newFrame.size.height < initialRect.size.height) {
            newFrame.size.height = initialRect.size.height;
        }
        if(IS_IPAD) {
            if(newFrame.size.height > maxLandscapeRect.size.height) {
                newFrame.size.height = maxLandscapeRect.size.height;
            }
        } else {
            if(newFrame.size.height > maxRect.size.height) {
                newFrame.size.height = maxRect.size.height;
            }
        }
        [self updateFrame:newFrame isMax:NO];
        
        lastContact = translatedPoint;
    }
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGFloat velocityY = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self].y);
        
        if(velocityY < 0) {
            [delegate customPlayerDidScrollInitialScreen];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [self updateFrame:initialRect isMax:NO];
            [UIView commitAnimations];
        } else if(velocityY > 0) {
            [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
                if(IS_IPAD) {
                    [self updateFrame:maxLandscapeRect isMax:YES];
                } else {
                    [self updateFrame:maxRect isMax:YES];
                }
            } completion:^(BOOL finished) {
                [delegate customPlayerDidScrollFullScreen];
            }];
        }
    }
}

- (void) updateFrame:(CGRect) newFrame isMax:(BOOL) isMax {
    self.frame = newFrame;
    playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    controlView.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40);
    [controlView updateInnerFrames];
}

- (void) willDismiss {
    if(player) {
        [player pause];
        [playerLayer removeFromSuperlayer];
        player = nil;
    }
}

- (void) willDisappear {
    if(player) {
        [player pause];
    }
}

- (void) dealloc {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
}

- (void) mirrorRotation:(UIInterfaceOrientation) orientation {
    if(IS_IPAD)
        return;
    
    if(self.player.rate == 0.0f) {
        [self updateFrame:initialRect isMax:NO];
        return;
    }

    if(orientation == UIInterfaceOrientationLandscapeLeft ) {
        [self updateFrame:self.maxLandscapeRect isMax:YES];
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        [self updateFrame:self.maxLandscapeRect isMax:YES];
    } else {
        [self updateFrame:initialRect isMax:NO];
    }
}

@end

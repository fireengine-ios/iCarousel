//
//  CustomAVControl.m
//
//  Created by Mahir on 4/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "CustomAVControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Util.h"

static void *VLAirplayButtonObservationContext = &VLAirplayButtonObservationContext;

@implementation CustomAVControl

@synthesize delegate;
@synthesize playButton;
@synthesize pauseButton;
@synthesize volumeButton;
@synthesize fullScreenButton;
@synthesize customVolumeView;
@synthesize airPlayView;
@synthesize totalDuration;
@synthesize passedDuration;
@synthesize separator;
@synthesize slider;
@synthesize totalTimeInSec;
@synthesize volumeLevels;

- (id)initWithFrame:(CGRect)frame withTotalDuration:(NSString *) totalDur {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];

        volumeLevels = [[NSMutableArray alloc] init];
        
        passedDuration = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 30, 20)];
        passedDuration.backgroundColor = [UIColor clearColor];
        passedDuration.textColor = [Util UIColorForHexColor:@"BEBEBE"];
        passedDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:11];
        passedDuration.adjustsFontSizeToFitWidth = YES;
        passedDuration.text = @"00:00";
        [self addSubview:passedDuration];

        totalDuration = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 15, 30, 20)];
        totalDuration.backgroundColor = [UIColor clearColor];
        totalDuration.textColor = [Util UIColorForHexColor:@"BEBEBE"];
        totalDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:11];
        totalDuration.adjustsFontSizeToFitWidth = YES;
        totalDuration.text = @"00:00";//totalDur;
        [self addSubview:totalDuration];

        slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 15, self.frame.size.width - 100, 20)];
        [slider setThumbImage:[UIImage imageNamed:@"bttn-player-handle.png"] forState:UIControlStateNormal];
        UIImage *sliderMax = [UIImage imageNamed:@"player_track.png"];
        sliderMax=[sliderMax resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch];
        UIImage *sliderMin = [UIImage imageNamed:@"player_progress.png"];
        sliderMin=[sliderMin resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch] ;
        [slider setMinimumTrackImage:sliderMin forState:UIControlStateNormal];
        [slider setMaximumTrackImage:sliderMax forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        slider.isAccessibilityElement = YES;
        slider.accessibilityIdentifier = @"sliderAVControl";
        [self addSubview:slider];
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"1e1e1e"];
        [self addSubview:separator];

        volumeButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 72, 16, 16) withImageName:@"volume_button.png"];
        volumeButton.hidden = NO;
        [volumeButton addTarget:self action:@selector(volumeClicked) forControlEvents:UIControlEventTouchUpInside];
        volumeButton.isAccessibilityElement = YES;
        volumeButton.accessibilityIdentifier = @"volumeButtonAVControl";
        [self addSubview:volumeButton];
        
        playButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 32)/2, 54, 32, 52) withImageName:@"play_icon.png"];
        playButton.hidden = NO;
        [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
        playButton.isAccessibilityElement = YES;
        playButton.accessibilityIdentifier = @"playButtonAVControl";
        [self addSubview:playButton];
        
        pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 32)/2, 54, 32, 52) withImageName:@"pause_icon.png"];
        pauseButton.hidden = YES;
        [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
        pauseButton.isAccessibilityElement = YES;
        pauseButton.accessibilityIdentifier = @"pauseButtonAVControl";
        [self addSubview:pauseButton];

        airPlayView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-54, 60, 44, 40)];
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, airPlayView.frame.size.width, airPlayView.frame.size.height)];
        volumeView.showsRouteButton = YES;
        volumeView.showsVolumeSlider = NO;
        [volumeView routeButtonRectForBounds:self.airPlayView.bounds];
        [airPlayView addSubview:volumeView];

        [self addSubview:airPlayView];
        
        customVolumeView = [[VolumeSliderView alloc] initWithFrame:CGRectMake(0, 51, self.frame.size.width, 59)];
        customVolumeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];
        customVolumeView.hidden = YES;
        customVolumeView.delegate = self;
        customVolumeView.isAccessibilityElement = YES;
        customVolumeView.accessibilityIdentifier = @"volumeViewAVControl";
        [self addSubview:customVolumeView];

        /*
        fullScreenButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 0, 44, 40) withImageName:@"bttn-video-expend.png"];
        [fullScreenButton addTarget:self action:@selector(fullScreenClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullScreenButton];
         */

    }
    return self;
}

#pragma mark VolumeSlider Delegate

- (void) volumeSliderDidSelectMax {
    [delegate customAVShouldChangeVolumeTo:1.0f];
}

- (void) volumeSliderDidSelectMute {
    [delegate customAVShouldChangeVolumeTo:0.0f];
}

- (void) volumeSliderDidChangeTo:(float)newVolumeVal {
    [delegate customAVShouldChangeVolumeTo:newVolumeVal];
}

- (void) initialVolumeLevel:(float) level {
    [customVolumeView setInitialVolumeLevels:level];
    /*
    int currentLevel = floor(level / 0.04f);
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= currentLevel) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
     */
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
    [delegate customAVShouldPlay];
}

- (void) pauseClicked {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    [delegate customAVShouldPause];
}

- (void) volumeClicked {
    customVolumeView.hidden = NO;
    [self bringSubviewToFront:customVolumeView];
    [self performSelector:@selector(hideVolumeView) withObject:nil afterDelay:4.0f];
}

- (void) hideVolumeView {
    customVolumeView.hidden = YES;
}

- (void) volumeFullClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyActivate];
    }
    [delegate customAVShouldChangeVolumeTo:1.0f];
//    [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0f];
}

- (void) volumeMuteClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyDeactivate];
    }
    [delegate customAVShouldChangeVolumeTo:0.0f];
//    [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0f];
}

- (void) volumeLevelIndicatorWasSelected:(int)levelSelected {
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= levelSelected) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }

    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    [delegate customAVShouldChangeVolumeTo:(UIInterfaceOrientationIsLandscape(currentOrientation) ? 0.02 : 0.04)*levelSelected];
}

- (void) fullScreenClicked {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(!UIDeviceOrientationIsLandscape(orientation) && UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        [delegate customAVShouldBeFullScreen];
    }
//    [fullScreenButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [fullScreenButton addTarget:self action:@selector(initialScreenClicked) forControlEvents:UIControlEventTouchUpInside];
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
            [delegate customAVShouldSeek:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
		}
	}
}

- (void) updateInnerFrames {
    passedDuration.frame = CGRectMake(10, 15, 30, 20);
    totalDuration.frame = CGRectMake(self.frame.size.width-40, 15, 30, 20);
    slider.frame = CGRectMake(50, 15, self.frame.size.width - 100, 20);
    volumeButton.frame = CGRectMake(10, 72, 16, 16);
    playButton.frame = CGRectMake((self.frame.size.width - 32)/2, 54, 32, 52);
    pauseButton.frame = CGRectMake((self.frame.size.width - 32)/2, 54, 32, 52);
    airPlayView.frame = CGRectMake(self.frame.size.width-54, 60, 44, 40);
    customVolumeView.frame = CGRectMake(0, 51, self.frame.size.width, 59);
    separator.frame = CGRectMake(0, 50, self.frame.size.width, 1);
    [customVolumeView updateInnerItems];

    /* check mahir
    volumeMuteButton.frame = CGRectMake(10, 22, 19, 16);
    volumeFullButton.frame = CGRectMake(self.frame.size.width - 29, 22, 19, 16);
    
    for(int i=0; i<[volumeLevels count]; i++) {
        VolumeLevelIndicator *volIndicator = [volumeLevels objectAtIndex:i];
        [volIndicator removeFromSuperview];
    }

    [volumeLevels removeAllObjects];
    
    int newLevelCount = UIInterfaceOrientationIsLandscape(currentOrientation) ? 48 : 23;
    
    for(int i=0; i<newLevelCount; i++) {
        VolumeLevelIndicator *volIndicator = [[VolumeLevelIndicator alloc] initWithFrame:CGRectMake(50 + (i-1)*10, 26, 8, 8) withLevel:(i+1)];
        volIndicator.delegate = self;
        [customVolumeView addSubview:volIndicator];
        
        [volumeLevels addObject:volIndicator];
    }
     */

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

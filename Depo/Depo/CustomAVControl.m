//
//  CustomAVControl.m
//
//  Created by Mahir on 4/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "CustomAVControl.h"
#import <MediaPlayer/MediaPlayer.h>

static void *VLAirplayButtonObservationContext = &VLAirplayButtonObservationContext;

@implementation CustomAVControl

@synthesize delegate;
@synthesize playButton;
@synthesize pauseButton;
@synthesize fullScreenButton;
@synthesize airPlayView;
@synthesize totalDuration;
@synthesize passedDuration;
@synthesize slider;
@synthesize totalTimeInSec;

- (id)initWithFrame:(CGRect)frame withTotalDuration:(NSString *) totalDur {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];

        playButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40) withImageName:@"bttn-video-play.png"];
        playButton.hidden = NO;
        [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];

        pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40) withImageName:@"bttn-video-pause.png"];
        pauseButton.hidden = YES;
        [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pauseButton];
        
        passedDuration = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 25, 20)];
        passedDuration.backgroundColor = [UIColor clearColor];
        passedDuration.textColor = [UIColor whiteColor];
        passedDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:9];
        passedDuration.adjustsFontSizeToFitWidth = YES;
        passedDuration.text = @"00:00";
        [self addSubview:passedDuration];

        totalDuration = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-110, 10, 25, 20)];
        totalDuration.backgroundColor = [UIColor clearColor];
        totalDuration.textColor = [UIColor whiteColor];
        totalDuration.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:9];
        totalDuration.adjustsFontSizeToFitWidth = YES;
        totalDuration.text = @"00:00";//totalDur;
        [self addSubview:totalDuration];

        airPlayView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-88, 0, 44, 40)];
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, airPlayView.frame.size.width, airPlayView.frame.size.height)];
        volumeView.showsRouteButton = YES;
        volumeView.showsVolumeSlider = NO;
        [volumeView routeButtonRectForBounds:self.airPlayView.bounds];
        [airPlayView addSubview:volumeView];

        [self addSubview:airPlayView];
        
        fullScreenButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 0, 44, 40) withImageName:@"bttn-video-expend.png"];
        [fullScreenButton addTarget:self action:@selector(fullScreenClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullScreenButton];

        slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 10, self.frame.size.width - 200, 20)];
        [slider setThumbImage:[UIImage imageNamed:@"bttn-player-handle.png"] forState:UIControlStateNormal];
        UIImage *sliderMax = [UIImage imageNamed:@"player_track.png"];
        sliderMax=[sliderMax resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch];
        UIImage *sliderMin = [UIImage imageNamed:@"player_progress.png"];
        sliderMin=[sliderMin resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3) resizingMode:UIImageResizingModeStretch] ;
        [slider setMinimumTrackImage:sliderMin forState:UIControlStateNormal];
        [slider setMaximumTrackImage:sliderMax forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];

    }
    return self;
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
    totalDuration.frame = CGRectMake(self.frame.size.width-110, 10, 25, 20);
    fullScreenButton.frame = CGRectMake(self.frame.size.width-44, 0, 44, 40);
    slider.frame = CGRectMake(80, 10, self.frame.size.width - 200, 20);
    airPlayView.frame = CGRectMake(self.frame.size.width-88, 0, 44, 40);
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

//
//  VolumeSliderView.m
//  Depo
//
//  Created by Mahir on 13/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "VolumeSliderView.h"

@implementation VolumeSliderView

@synthesize delegate;
@synthesize volumeLevels;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"video-player-bckgrnd.png"]];
        
        CustomButton *volumeMuteButton = [[CustomButton alloc] initWithFrame:CGRectMake(3, 15, 30, 30) withImageName:@"volume_mute.png"];
        [volumeMuteButton addTarget:self action:@selector(volumeMuteClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:volumeMuteButton];
        
        CustomButton *volumeFullButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 36, 15, 30, 30) withImageName:@"volume_full.png"];
        [volumeFullButton addTarget:self action:@selector(volumeFullClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:volumeFullButton];
        
        volumeLevels = [[NSMutableArray alloc] init];
        
        for(int i=0; i<23; i++) {
            VolumeLevelIndicator *volIndicator = [[VolumeLevelIndicator alloc] initWithFrame:CGRectMake(50 + (i-1)*10, 26, 8, 8) withLevel:(i+1)];
            volIndicator.userInteractionEnabled = NO;
            volIndicator.delegate = self;
            [self addSubview:volIndicator];
            
            [volumeLevels addObject:volIndicator];
        }
    }
    return self;
}

- (void) volumeLevelIndicatorWasSelected:(int)levelSelected {
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= levelSelected) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
    [delegate volumeSliderDidChangeTo:0.04*levelSelected];
}

- (void) volumeMuteClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyDeactivate];
    }
    [delegate volumeSliderDidSelectMute];
}

- (void) volumeFullClicked {
    for(VolumeLevelIndicator *level in volumeLevels) {
        [level manuallyActivate];
    }
    [delegate volumeSliderDidSelectMax];
}

- (void) setInitialVolumeLevels:(float) level {
    int currentLevel = floor(level / 0.04f);
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.level <= currentLevel) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.frame.origin.x <= point.x) {
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    int activeLevelCount = 0;
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.frame.origin.x <= point.x) {
            activeLevelCount ++;
            [level manuallyActivate];
        } else {
            [level manuallyDeactivate];
        }
    }
    [delegate volumeSliderDidChangeTo:0.04*activeLevelCount];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int activeLevelCount = 0;
    for(VolumeLevelIndicator *level in volumeLevels) {
        if(level.isActive) {
            activeLevelCount ++;
        } else {
            break;
        }
    }
    [delegate volumeSliderDidChangeTo:0.04*activeLevelCount];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

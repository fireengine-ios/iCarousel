//
//  CustomAVControl.h
//
//  Created by Mahir on 4/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "VolumeLevelIndicator.h"

@protocol CustomAVControlDelegate <NSObject>
- (void) customAVShouldPause;
- (void) customAVShouldPlay;
- (void) customAVShouldSeek:(CMTime) timeToSeek;
- (void) customAVShouldBeFullScreen;
- (void) customAVShouldChangeVolumeTo:(float) volumeVal;
@end

@interface CustomAVControl : UIView <VolumeLevelDelegate>

@property (nonatomic, strong) id<CustomAVControlDelegate> delegate;
@property (nonatomic, strong) CustomButton *playButton;
@property (nonatomic, strong) CustomButton *pauseButton;
@property (nonatomic, strong) CustomButton *fullScreenButton;
@property (nonatomic, strong) CustomButton *volumeButton;
@property (nonatomic, strong) UIView *airPlayView;
@property (nonatomic, strong) UIView *customVolumeView;
@property (nonatomic, strong) UILabel *totalDuration;
@property (nonatomic, strong) UILabel *passedDuration;
@property (nonatomic, strong) NSMutableArray *volumeLevels;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) CustomButton *volumeMuteButton;
@property (nonatomic, strong) CustomButton *volumeFullButton;
@property (nonatomic) int totalTimeInSec;

- (id)initWithFrame:(CGRect)frame withTotalDuration:(NSString *) totalDur;
- (void) updateTime:(int) time withTotalDuration:(int) totalDur;
- (void) videoDidStart;
- (void) videoDidStop;
- (void) updateInnerFrames;
- (void) initialVolumeLevel:(float) level;

@end

//
//  CustomAVPlayer.h
//
//  Created by Mahir on 4/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MetaFile.h"
#import "CustomAVControl.h"

@protocol CustomAVPlayerDelegate <NSObject>
- (void) customPlayerDidScrollFullScreen;
- (void) customPlayerDidScrollInitialScreen;
@end

@interface CustomAVPlayer : UIView <CustomAVControlDelegate>

@property (nonatomic, strong) id<CustomAVPlayerDelegate> delegate;
@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (assign) BOOL seekToZeroBeforePlay;
@property (assign) BOOL controlVisible;
@property (nonatomic) CGRect initialRect;
@property (nonatomic) CGRect maxRect;
@property (nonatomic) CGRect maxLandscapeRect;
@property (nonatomic) CGPoint lastContact;
@property (nonatomic, strong) MetaFile *video;
@property (nonatomic, strong) CustomAVControl *controlView;

- (id) initWithFrame:(CGRect)frame withVideo:(MetaFile *) _video;
- (void) initializePlayer;
- (void) willDismiss;
- (void) updateFrame:(CGRect) newFrame isMax:(BOOL) isMax;
- (void) mirrorRotation:(UIInterfaceOrientation) orientation;
- (void) triggerInfo;

@end

//
//  VideoView.m
//  Depo
//
//  Created by Metin Guler on 27/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "VideoView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface VideoView ()

@property (atomic) BOOL isVideoReady;
@property (atomic) BOOL playVideoWhenReady;

@end

@implementation VideoView

- (instancetype)initWithFrame:(CGRect)frame withFile:(MetaFile*)mfile
{
    self = [super initWithFrame:frame];
    if (self) {
        _file = mfile;
        
        NSLog(@"video view frame = %@", NSStringFromCGRect(frame));
        _avPlayer = [[CustomAVPlayer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                withVideo:mfile];
        
        _avPlayer.delegate = self;
        [self addSubview:_avPlayer];
        _avPlayer.shouldManuallyAutoRotate = true;
        
        [APPDELEGATE.session pauseAudioItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoIsReady:) name:VIDEO_READY_TO_PLAY_NOTIFICATION object:nil];
        
        // thumbail image
        _thumbailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _thumbailImage.contentMode = UIViewContentModeScaleAspectFit;
        
        NSString *imgUrlStr = [self.file.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [_thumbailImage sd_setImageWithURL:[NSURL URLWithString:imgUrlStr] ];
        [self addSubview:_thumbailImage];
        
        // play button
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, 68, 68);
        _playButton.center = CGPointMake(frame.size.width /2, frame.size.height /2);
        [_playButton setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    return self;
}

- (void) resizeVideoView {
    [_avPlayer updateFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) isMax:true];
    _playButton.center = CGPointMake(self.frame.size.width /2, self.frame.size.height /2);
    _thumbailImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void) playVideo:(UIButton*)sender {
    [self showLoading];
    [_avPlayer initializePlayer];
    [_playButton removeFromSuperview];
    [_thumbailImage removeFromSuperview];
}

- (void) stopVideoAndReCreateView {
    [self stopVideo];
    
    _avPlayer = [[CustomAVPlayer alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                            withVideo:_file];
    _avPlayer.delegate = self;
    _avPlayer.shouldManuallyAutoRotate = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:_avPlayer];
        [self addSubview:_thumbailImage];
        [self addSubview:_playButton];
    });
}

- (void) stopVideo {
    if(_avPlayer) {
        [_avPlayer willDismiss];
        [_avPlayer removeFromSuperview];
    }
    _avPlayer = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
}

- (void) videoIsReady:(id)sender {
    [self hideLoading];
    [_avPlayer.player play];
}

- (void)dealloc {
    if(_avPlayer) {
        [_avPlayer willDismiss];
    }
    _avPlayer = nil;
}

#pragma mark - Loading Functions

- (void) showLoading {
    // progress view
    _progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
    _progress.opacity = 0.4f;
    [self addSubview:_progress];
    
    [_progress show:YES];
    [self bringSubviewToFront:_progress];
}

- (void) hideLoading {
    [_progress hide:NO];
    // remove after animation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.progress removeFromSuperview];
        _progress = nil;
    });
}

#pragma mark - CustomAVPlayerDelegate

- (void) customPlayerDidStartPlay {
    if ([_delegate respondsToSelector:@selector(videoDidStartPlay)]) {
        [_delegate videoDidStartPlay];
    }
}

- (void) customPlayerDidPause {
    if ([_delegate respondsToSelector:@selector(videoDidPause)]) {
        [_delegate videoDidPause];
    }
}

- (void) customPlayerDidScrollFullScreen {
}

- (void) customPlayerDidScrollInitialScreen {
}

- (void) controlVisibilityChanged {
    if ([_delegate respondsToSelector:@selector(controlVisibilityChanged:)]) {
        [_delegate controlVisibilityChanged:_avPlayer.controlVisible];
    }
}

@end

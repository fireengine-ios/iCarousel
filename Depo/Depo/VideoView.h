//
//  VideoView.h
//  Depo
//
//  Created by Metin Guler on 27/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAVPlayer.h"
#import "MBProgressHUD.h"

@protocol VideoViewDelegate <NSObject>
@optional
- (void) videoDidStartPlay;
- (void) videoDidPause;
- (void) controlVisibilityChanged:(BOOL)visibility;

@end

@interface VideoView : UIView <CustomAVPlayerDelegate>

@property (nonatomic, assign) id<VideoViewDelegate> delegate;
@property (nonatomic) MetaFile *file;
@property (nonatomic) CustomAVPlayer *avPlayer;
@property (nonatomic) UIImageView *thumbailImage;
@property (nonatomic) UIButton *playButton;
@property (nonatomic, strong) MBProgressHUD *progress;

- (instancetype)initWithFrame:(CGRect)frame withFile:(MetaFile*)mfile;

- (void) stopVideoAndReCreateView;
- (void) stopVideo;

- (void) resizeVideoView;
- (void) showLoading;
- (void) hideLoading;

@end

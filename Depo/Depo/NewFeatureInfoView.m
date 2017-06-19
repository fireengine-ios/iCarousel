//
//  NewFeatureInfoView.m
//  Depo
//
//  Created by Mahir Tarlan on 13/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "NewFeatureInfoView.h"
#import "Util.h"
#import "CustomLabel.h"
#import "SimpleButton.h"
#import "AppConstants.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "CustomButton.h"

@interface NewFeatureInfoView() {
    AVPlayer *avPlayer;
}
@end

@implementation NewFeatureInfoView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.6f;
        [self addSubview:maskView];
        
        NSString *videoName = @"lifebox_EN";
        if([[Util readLocaleCode] isEqualToString:@"tr"]) {
            videoName = @"lifebox_TR";
        }
        NSURL *mp4Url = [[NSBundle mainBundle] URLForResource:videoName withExtension:@"mp4"];
        
        avPlayer = [AVPlayer playerWithURL:mp4Url];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;

        float videoWidth = self.frame.size.width;
        float videoHeight = self.frame.size.height;
//        float topIndex = IS_IPAD ? self.frame.size.height/2 - videoHeight : 50;
        
        AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        videoLayer.frame = CGRectMake((self.frame.size.width - videoWidth)/2, (self.frame.size.height - videoHeight)/2, videoWidth, videoHeight);
        if(IS_IPAD) {
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        } else {
            videoLayer.videoGravity = AVLayerVideoGravityResize;
        }
        videoLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:videoLayer];
        [avPlayer play];
        
        CustomButton *closeButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 10, 40, 40) withCenteredImageName:@"close_icon.png"];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:closeButton];

//        topIndex += videoHeight + 30;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[avPlayer currentItem]];
        
        /*
        UIImage *bgImg = [UIImage imageNamed:@"img_lifebox.png"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - bgImg.size.width)/2, IS_IPHONE_4_OR_LESS ? 30 : 60, bgImg.size.width, bgImg.size.height)];
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];
         */
        
        /*
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, topIndex, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"333333"] withText:NSLocalizedString(@"LifeboxTeaserInfoLabel", @"") withAlignment:NSTextAlignmentCenter numberOfLines:1];
        [self addSubview:infoLabel];

        NSString *subInfoText = NSLocalizedString(@"LifeboxTeaserInfoSubLabel", @"");
        float subInfoHeight = [Util calculateHeightForText:subInfoText forWidth:self.frame.size.width - 40 forFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16]] + 10;
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.origin.y + infoLabel.frame.size.height + 20, self.frame.size.width - 40, subInfoHeight) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:subInfoText withAlignment:NSTextAlignmentCenter numberOfLines:0];
        [self addSubview:subInfoLabel];
         */

        /*
        SimpleButton *dismissButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 200)/2, self.frame.size.height - 80, 200, 60) withTitle:NSLocalizedString(@"Continue", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
         */
    }
    return self;
}

- (void) playerFinishedPlaying {
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

- (void) dismiss {
    if(avPlayer) {
        [avPlayer pause];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self removeFromSuperview];
}

@end

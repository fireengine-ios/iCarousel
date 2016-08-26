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
        
        CustomButton *closeButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 10, 40, 40) withCenteredImageName:@"close_icon.png"];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        NSURL *mp4Url = [[NSBundle mainBundle] URLForResource:@"lifebox_teaser" withExtension:@"mp4"];
        
        avPlayer = [AVPlayer playerWithURL:mp4Url];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;

        AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        videoLayer.frame = CGRectMake(30, 30, self.frame.size.width - 60, self.frame.size.width - 40);
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:videoLayer];
        [avPlayer play];
        
        float topIndex = self.frame.size.width + 10;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[avPlayer currentItem]];
        
        /*
        UIImage *bgImg = [UIImage imageNamed:@"img_lifebox.png"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - bgImg.size.width)/2, IS_IPHONE_4_OR_LESS ? 30 : 60, bgImg.size.width, bgImg.size.height)];
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];
         */
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, topIndex, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"333333"] withText:NSLocalizedString(@"LifeboxTeaserInfoLabel", @"") withAlignment:NSTextAlignmentCenter numberOfLines:1];
        [self addSubview:infoLabel];

        NSString *subInfoText = NSLocalizedString(@"LifeboxTeaserInfoSubLabel", @"");
        float subInfoHeight = [Util calculateHeightForText:subInfoText forWidth:self.frame.size.width - 40 forFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16]] + 10;
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.origin.y + infoLabel.frame.size.height + 20, self.frame.size.width - 40, subInfoHeight) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:subInfoText withAlignment:NSTextAlignmentCenter numberOfLines:0];
        [self addSubview:subInfoLabel];

        /*
        SimpleButton *dismissButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 200)/2, self.frame.size.height - 80, 200, 60) withTitle:NSLocalizedString(@"Continue", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
         */
    }
    return self;
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

- (void) dismiss {
    [self removeFromSuperview];
}

@end

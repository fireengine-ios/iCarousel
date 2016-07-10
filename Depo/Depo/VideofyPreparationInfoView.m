//
//  VideofyPreparationInfoView.m
//  Depo
//
//  Created by Mahir Tarlan on 10/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyPreparationInfoView.h"
#import "CustomLabel.h"
#import "CustomButton.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@implementation VideofyPreparationInfoView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.8f;
        [self addSubview:backgroundView];
        
        
        UIImage *cloudImg = [UIImage imageNamed:@"welcome_cloud.png"];
        UIImageView *cloudImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - cloudImg.size.width)/2, IS_IPHONE_4_OR_LESS ? 50 : 80, cloudImg.size.width, cloudImg.size.height)];
        cloudImgView.image = cloudImg;
        [self addSubview:cloudImgView];

        UIFont *infoFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:16];
        float infoHeight = [Util calculateHeightForText:NSLocalizedString(@"VideofyPreparationMessage", @"") forWidth:self.frame.size.width - 60 forFont:infoFont] + 10;
        
        CustomLabel *infoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(30, cloudImgView.frame.origin.y + cloudImgView.frame.size.height + (IS_IPHONE_4_OR_LESS ? 10 : 30), self.frame.size.width - 60, infoHeight) withFont:infoFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"VideofyPreparationMessage", @"") withAlignment:NSTextAlignmentCenter numberOfLines:0];
        [self addSubview:infoTitle];
        
        CustomButton *homepageButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 280)/2, infoTitle.frame.origin.y + infoTitle.frame.size.height + (IS_IPHONE_4_OR_LESS ? 30 : 60), 280, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"HomePage", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [homepageButton addTarget:self action:@selector(triggerHome) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:homepageButton];
    }
    return self;
}

- (void) triggerHome {
    [APPDELEGATE triggerHome];
}

@end

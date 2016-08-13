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

@implementation NewFeatureInfoView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *bgImg = [UIImage imageNamed:@"img_lifebox.png"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - bgImg.size.width)/2, IS_IPHONE_4_OR_LESS ? 30 : 60, bgImg.size.width, bgImg.size.height)];
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, bgImgView.frame.origin.y + bgImgView.frame.size.height + (IS_IPHONE_4_OR_LESS ? 5 : 20), self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"333333"] withText:NSLocalizedString(@"NewFeatureInfoLabel", @"") withAlignment:NSTextAlignmentCenter numberOfLines:1];
        [self addSubview:infoLabel];
        
        NSString *subInfoText = NSLocalizedString(@"NewFeatureInfoSubLabel", @"");
        float subInfoHeight = [Util calculateHeightForText:subInfoText forWidth:self.frame.size.width - 40 forFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16]] + 10;
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.origin.y + infoLabel.frame.size.height, self.frame.size.width - 40, subInfoHeight) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:subInfoText withAlignment:NSTextAlignmentCenter numberOfLines:0];
        [self addSubview:subInfoLabel];
        
        SimpleButton *dismissButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 200)/2, self.frame.size.height - 80, 200, 60) withTitle:NSLocalizedString(@"Continue", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
    }
    return self;
}

- (void) dismiss {
    [self removeFromSuperview];
}

@end

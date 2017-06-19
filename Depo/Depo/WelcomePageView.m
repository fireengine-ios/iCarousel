//
//  WelcomePageView.m
//  Depo
//
//  Created by Mahir Tarlan on 25/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "WelcomePageView.h"
#import "Util.h"
#import "AppConstants.h"
#import "CustomLabel.h"

@implementation WelcomePageView

- (id) initWithFrame:(CGRect)frame withBgImageName:(NSString *) imgName withTitle:(NSString *) titleVal withSubTitle:(NSString *) subTitleVal withIcon:(NSString *) iconName {
    if(self = [super initWithFrame:frame]) {
        
        float topIndex = IS_IPAD ? 150 : 0;
        
        UIImage *bgImg = [UIImage imageNamed:imgName];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];

        UIFont *infoFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:IS_IPHONE_4_OR_LESS ? 20 : 30];
        UIFont *subInfoFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:IS_IPHONE_4_OR_LESS ? 15 : 20];
        
        float infoWidth = self.frame.size.width - 40;
        if(IS_IPAD) {
            infoWidth = self.frame.size.width/2;
        }
        float infoHeight = [Util calculateHeightForText:titleVal forWidth:infoWidth forFont:infoFont] + 10;
        float subInfoHeight = [Util calculateHeightForText:subTitleVal forWidth:infoWidth forFont:subInfoFont] + 10;

        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.frame.size.width - infoWidth)/2, topIndex + (IS_IPHONE_4_OR_LESS ? 60 : 70), infoWidth, infoHeight) withFont:infoFont withColor:[UIColor whiteColor] withText:titleVal withAlignment:NSTextAlignmentLeft numberOfLines:0];
        [self addSubview:infoLabel];

        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.frame.size.width - infoWidth)/2, topIndex + (IS_IPHONE_4_OR_LESS ? 50 : 70) + infoHeight + (IS_IPHONE_4_OR_LESS ? 0 : 10), infoWidth, subInfoHeight) withFont:subInfoFont withColor:[UIColor whiteColor] withText:subTitleVal withAlignment:NSTextAlignmentLeft numberOfLines:0];
        [self addSubview:subInfoLabel];
        
        UIImage *iconImg = [UIImage imageNamed:iconName];
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - iconImg.size.width)/2, topIndex + subInfoLabel.frame.origin.y + subInfoLabel.frame.size.height + (IS_IPHONE_4_OR_LESS ? 0 : 10), iconImg.size.width, iconImg.size.height)];
        iconImgView.image = iconImg;
        [self addSubview:iconImgView];
    }
    return self;
}

@end

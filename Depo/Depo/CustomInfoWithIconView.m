//
//  CustomInfoWithIconView.m
//  Depo
//
//  Created by Mahir Tarlan on 08/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CustomInfoWithIconView.h"

@implementation CustomInfoWithIconView

@synthesize delegate;
@synthesize modalView;

- (id) initWithFrame:(CGRect) frame withIcon:(NSString *) iconName withInfo:(NSString *) infoVal withSubInfo:(NSString *) subInfoVal isCloseable:(BOOL) closableFlag {
    if(self = [super initWithFrame:frame]) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        UIImage *iconImg = [UIImage imageNamed:iconName];
        UIFont *infoFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
        UIFont *subInfoFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:13];
        
        int subInfoHeight = [Util calculateHeightForText:subInfoVal forWidth:240 forFont:subInfoFont] + 20;
        
        float modalHeight = iconImg.size.height + subInfoHeight + 100;
        
        modalView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 280)/2, (self.frame.size.height - modalHeight)/2, 280, modalHeight)];
        modalView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake((modalView.frame.size.width - iconImg.size.width)/2, 30, iconImg.size.width, iconImg.size.height)];
        iconImgView.image = iconImg;
        [modalView addSubview:iconImgView];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconImgView.frame.origin.y + iconImgView.frame.size.height + 10, modalView.frame.size.width, 20)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.text = infoVal;
        infoLabel.font = infoFont;
        infoLabel.textColor = [Util UIColorForHexColor:@"3fb0e8"];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        [modalView addSubview:infoLabel];
        
        UILabel *subInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.origin.y + infoLabel.frame.size.height, modalView.frame.size.width - 40, subInfoHeight)];
        subInfoLabel.backgroundColor = [UIColor clearColor];
        subInfoLabel.text = subInfoVal;
        subInfoLabel.font = subInfoFont;
        subInfoLabel.textColor = [Util UIColorForHexColor:@"555555"];
        subInfoLabel.textAlignment = NSTextAlignmentCenter;
        subInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subInfoLabel.numberOfLines = 0;
        [modalView addSubview:subInfoLabel];
        
        CustomButton *closeButton = [[CustomButton alloc] initWithFrame:CGRectMake(modalView.frame.size.width - 50, 10, 40, 40) withCenteredImageName:@"close_icon.png"];
        [closeButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:closeButton];

        [self addSubview:modalView];
    }
    return self;
}

- (void) triggerDismiss {
    [delegate customInfoWithIconViewDidDismiss];
    [self removeFromSuperview];
}

@end

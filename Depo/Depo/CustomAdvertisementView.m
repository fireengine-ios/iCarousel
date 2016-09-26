//
//  CustomAdvertisementView.m
//  Depo
//
//  Created by Gürhan KODALAK on 13/08/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "CustomAdvertisementView.h"
#import "Util.h"
#import "SimpleButton.h"
#import "AppUtil.h"

@implementation CustomAdvertisementView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame withMessage:(NSString *)message withBooleanOption:(BOOL)option withTitle:(NSString *) title {
    if (self == [super initWithFrame:frame]) {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImage.image = [UIImage imageNamed:@"siyah_bg@1x.png"];
        bgImage.alpha = 0.6;
        [self addSubview:bgImage];
        
        UIImageView *popUp = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, self.frame.size.height-40)];
        popUp.image = [UIImage imageNamed:@"bulut-bg-bos@1x.png"];
        popUp.backgroundColor = [UIColor clearColor];
        [self addSubview:popUp];
        
        float topIndex = IS_IPAD ? self.frame.size.height/2-100 : 20;
        int titleHeight = 80;
        if (title || [title isKindOfClass:[NSNull class]]) {
            titleHeight = 10 + [Util calculateHeightForText:title forWidth:self.frame.size.width-40 forFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:35]];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, topIndex, popUp.frame.size.width-40, titleHeight)];
            titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:35];
            titleLabel.numberOfLines = 0;
            //titleLabel.lineBreakMode = NSLineBreakByWordWrapping ;
            titleLabel.textColor = [Util UIColorForHexColor:@"5ba1c4"];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = title;
            [popUp addSubview:titleLabel];
        }
        
        int height = [Util calculateHeightForText:message forWidth:popUp.frame.size.width-20 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20]] ;
        
        UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topIndex + titleHeight + 50, popUp.frame.size.width-20 ,height)];
        explainLabel.text = message;
        explainLabel.textColor = [Util UIColorForHexColor:@"4f8caa"];
        explainLabel.numberOfLines = 0;
        explainLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:20];
        explainLabel.textAlignment = NSTextAlignmentCenter;
        [popUp addSubview:explainLabel];
        
        if (option) {
            SimpleButton *noButton = [[SimpleButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-90, (self.frame.size.width - 70)/2-5, 50) withTitle:NSLocalizedString(@"CancelButtonTittle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
            [noButton addTarget:self action:@selector(noClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:noButton];
            
            SimpleButton *yesButton = [[SimpleButton alloc] initWithFrame:CGRectMake(self.frame.size.width-35-noButton.frame.size.width, self.frame.size.height-90, (self.frame.size.width - 70)/2-5, 50) withTitle:NSLocalizedString(@"MoreStorageButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
            [yesButton addTarget:self action:@selector(yesClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:yesButton];
            
        }
        else {
            SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-90, self.frame.size.width - 60, 60) withTitle:NSLocalizedString(@"Okay", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
            [okButton addTarget:self action:@selector(okClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:okButton];
        }
        
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame withMessage:(NSString *)message withFullPackage:(BOOL)isFull withTitle:(NSString *) title {
    if (self == [super initWithFrame:frame]) {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImage.image = [UIImage imageNamed:@"siyah_bg@1x.png"];
        bgImage.alpha = 0.6;
        [self addSubview:bgImage];
        
        UIImageView *popUp = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, self.frame.size.height-40)];
        popUp.image = [UIImage imageNamed:@"bulut-bg-bos@1x.png"];
        popUp.backgroundColor = [UIColor clearColor];
        [self addSubview:popUp];
        int titleHeight = 80;
        if (title || [title isKindOfClass:[NSNull class]]) {
            titleHeight = 10 + [Util calculateHeightForText:title forWidth:self.frame.size.width-40 forFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:35]];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, popUp.frame.size.width-40, titleHeight)];
            titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:35];
            titleLabel.numberOfLines = 0;
            titleLabel.textColor = [Util UIColorForHexColor:@"5ba1c4"];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = title;
            [popUp addSubview:titleLabel];
        }
        
        int height = [Util calculateHeightForText:message forWidth:popUp.frame.size.width-20 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20]];
        UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleHeight+70,popUp.frame.size.width-20 ,height)];
        explainLabel.text = message;
        explainLabel.textColor = [Util UIColorForHexColor:@"4f8caa"];
        explainLabel.numberOfLines = 0;
        explainLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:20];
        explainLabel.textAlignment = NSTextAlignmentCenter;
        [popUp addSubview:explainLabel];
        
        if (isFull) {
            SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-90, self.frame.size.width - 60, 60) withTitle:NSLocalizedString(@"Okay", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
            [okButton addTarget:self action:@selector(okIsFullClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:okButton];

        }
    }
    return self;
}

- (void) yesClicked {
    [delegate advertisementViewYesClick];
}

- (void) noClicked {
    [delegate advertisementViewNoClick];
}

- (void) okClicked {
    [delegate advertisementViewOkClick];
}

- (void) okIsFullClicked {
    [delegate advertisementViewOkClickWhenFull];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

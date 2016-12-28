//
//  OnkatDepoPopUP.m
//  Depo
//
//  Created by Gürhan KODALAK on 24/06/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "OnkatDepoPopUP.h"
#import "Util.h"
#import "SimpleButton.h"

@implementation OnkatDepoPopUP

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImage.image = [UIImage imageNamed:@"siyah_bg@1x.png"];
        bgImage.alpha = 0.6;
        [self addSubview:bgImage];
        
        UIImageView *popUp = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, self.frame.size.height-40)];
        popUp.image = [UIImage imageNamed:@"bulut-bg-bos@1x.png"];
        popUp.backgroundColor = [UIColor clearColor];
        [self addSubview:popUp];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, popUp.frame.size.width-40, 90)];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:35];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [Util UIColorForHexColor:@"5ba1c4"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = NSLocalizedString(@"OnKatDepoTitle", @"");
        [popUp addSubview:titleLabel];
        
        UILabel *tenLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,110 , popUp.frame.size.width-40, 90)];
        tenLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:90];
        tenLabel.textColor = [Util UIColorForHexColor:@"4f8caa"];
        tenLabel.text = NSLocalizedString(@"Ten", @"");
        tenLabel.textAlignment = NSTextAlignmentCenter;
        [popUp addSubview:tenLabel];
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, popUp.frame.size.width-40, 35)];
        subtitleLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:30];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.textColor = [Util UIColorForHexColor:@"5ba1c4"];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.text =  NSLocalizedString(@"OnKatDepoSubTitle", @"");
        [popUp addSubview:subtitleLabel];

        
        UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250,popUp.frame.size.width-20 ,60)];
        explainLabel.text = NSLocalizedString(@"OnKatDepoExplain", @"");
        explainLabel.textColor = [Util UIColorForHexColor:@"4f8caa"];
        explainLabel.numberOfLines = 0;
        explainLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:20];
        explainLabel.textAlignment = NSTextAlignmentCenter;
        [popUp addSubview:explainLabel];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-90, self.frame.size.width - 60, 60) withTitle:NSLocalizedString(@"Okay", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(okButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        okButton.isAccessibilityElement = YES;
        okButton.accessibilityIdentifier = @"okButtonOnKatDepo";
        [self addSubview:okButton];
        
    }
    return self;
}

- (void) okButtonClicked {
    [delegate dismissOnKatView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

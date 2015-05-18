//
//  OfferRectangleView.m
//  Depo
//
//  Created by gurhan on 28/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "OfferRectangleView.h"
#import "Util.h"

@implementation OfferRectangleView

@synthesize delegate;
@synthesize selectedOffer;
@synthesize buyButton;
@synthesize buyMonthlyButton;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer withColor:(NSString *)colorCode {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:colorCode];
        self.layer.cornerRadius = 2.0;
        self.selectedOffer = offer;
        UILabel *quotaLabel = [ [UILabel alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width*3/4-4, self.frame.size.height-4)];
        quotaLabel.backgroundColor = [Util UIColorForHexColor:@"fbfbfc"];
        NSString *periodStr = [self getOfferPeriodString:offer];
        NSString *quotaStr = [NSString stringWithFormat:@"%@ %@ TL ",periodStr, offer.price];
        quotaLabel.text = quotaStr;
        quotaLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        quotaLabel.textAlignment = NSTextAlignmentCenter;
        quotaLabel.textColor = [Util UIColorForHexColor:@"999999"];
        [self addSubview:quotaLabel];
        
        buyButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*3/4-2, 0, self.frame.size.width/4+4, self.frame.size.height)];
        [buyButton addTarget:self action:@selector(buyButtonClicked:) forControlEvents:UIControlEventTouchDown];
        [buyButton addTarget:self action:@selector(buyButtonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [buyButton addTarget:self action:@selector(buyButtonNormal:) forControlEvents:UIControlEventTouchUpOutside];
        [buyButton setBackgroundColor:[UIColor clearColor]];
        [buyButton setImage:[UIImage imageNamed:@"icon_settings_arrow.png"] forState:UIControlStateNormal];
        buyButton.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5);
        buyButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        buyButton.adjustsImageWhenHighlighted = NO;
        [self addSubview:buyButton];
        
            
        
    }
    return self;
}

- (id) initWithRoundedFrame:(CGRect)frame withOffer:(Offer *)offer withColor:(NSString *)colorCode {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:colorCode];
        self.selectedOffer = offer;
        UILabel *quotaLabel = [ [UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*3/4, self.frame.size.height)];
        quotaLabel.backgroundColor = [Util UIColorForHexColor:@"fbfbfc"];
        NSString *periodStr = [self getOfferPeriodString:offer];
        NSString *quotaStr = [NSString stringWithFormat:@"%@ %@ TL ",periodStr, offer.price];
        quotaLabel.text = quotaStr;
        quotaLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        quotaLabel.textAlignment = NSTextAlignmentCenter;
        quotaLabel.textColor = [Util UIColorForHexColor:@"999999"];
        [self addSubview:quotaLabel];
        
        buyMonthlyButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*3/4-2, 0, self.frame.size.width/4+4, self.frame.size.height)];
        [buyMonthlyButton addTarget:self action:@selector(buyButtonClicked:) forControlEvents:UIControlEventTouchDown];
        [buyMonthlyButton addTarget:self action:@selector(buyButtonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [buyMonthlyButton addTarget:self action:@selector(buyButtonNormal:) forControlEvents:UIControlEventTouchUpOutside];
        [buyMonthlyButton setBackgroundColor:[UIColor clearColor]];
        [buyMonthlyButton setImage:[UIImage imageNamed:@"icon_settings_arrow.png"] forState:UIControlStateNormal];
        buyMonthlyButton.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5);
        buyMonthlyButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        buyMonthlyButton.adjustsImageWhenHighlighted = NO;
        [self addSubview:buyMonthlyButton];

    }
    return self;
}



- (void) buyButtonClicked:(UIButton *) sender {
    if ([self.backgroundColor isEqual:[Util UIColorForHexColor:@"fede32"]]) {
        self.backgroundColor = [Util UIColorForHexColor:@"fdca2e"];
    }
    else if([self.backgroundColor isEqual:[Util UIColorForHexColor:@"cfd3dc"]]) {
        self.backgroundColor = [Util UIColorForHexColor:@"c0c5d0"];
    }
}

- (void) buyButtonNormal:(UIButton *) sender  {
    if ([self.backgroundColor isEqual:[Util UIColorForHexColor:@"fdca2e"]]) {
        self.backgroundColor = [Util UIColorForHexColor:@"fede32"];
    }
    else if([self.backgroundColor isEqual:[Util UIColorForHexColor:@"c0c5d0"]]) {
        self.backgroundColor = [Util UIColorForHexColor:@"cfd3dc"];
    }
    [delegate purchaseOffer:selectedOffer];

}

- (NSString *) getOfferPeriodString :(Offer *) offer {
    if ([offer.period isEqualToString:@"MONTH"]) {
        return NSLocalizedString(@"MONTHLY", @"");
    }
    else
        return NSLocalizedString(@"YEARLY", @"");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  BeforePurchasingView.m
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "BeforePurchasingView.h"
#import "Util.h"
#import "SimpleButton.h"

@implementation BeforePurchasingView

@synthesize delegate;
@synthesize toActivateOffer;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"f8f9fa"];
        self.layer.cornerRadius = 6.0;
        self.toActivateOffer = offer;
        
        if(offer.offerType == OfferTypeTurkcell) {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, 30)];
            offerName.text = [self getPackageDisplayName:offer.role];
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerName.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerName];
            
            UILabel *offerQuota = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.frame.size.width-40, 30)];
            offerQuota.text = [NSString stringWithFormat:@"%@ GB", [self quotaCalculator:offer.quota]];
            offerQuota.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerQuota.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerQuota.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerQuota];
        } else {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.frame.size.width-40, 30)];
            offerName.text = offer.name;
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerName.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerName];
        }
        
        UILabel *offerPrice = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, self.frame.size.width-40, 20)];
        if(offer.rawPrice > 0.0f) {
            if(offer.offerType == OfferTypeApple) {
                NSString *strKey = [NSString stringWithFormat:@"PERIOD_%@", offer.period];
                NSString *periodInfo = NSLocalizedString(strKey, "");
                offerPrice.text = [NSString stringWithFormat:@"%@ %@", periodInfo, offer.price];
            } else {
                offerPrice.text = [NSString stringWithFormat:@"%@ %@ TL", [offer.period isEqualToString:@"MONTH"] ? NSLocalizedString(@"MONTHLY", "") : NSLocalizedString(@"YEARLY", ""), offer.price];
            }
        } else {
            offerPrice.text = NSLocalizedString(@"SubscriptionFree", @"");
        }
        offerPrice.textColor = [Util UIColorForHexColor:@"363e4e"];
        offerPrice.textAlignment = NSTextAlignmentCenter;
        offerPrice.font = [UIFont fontWithName:@"TurkcellSaturaReg" size:20];
        [self addSubview:offerPrice];
        
        SimpleButton *buyButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, 140, self.frame.size.width-40, 50) withTitle:NSLocalizedString(@"PurchasePackage", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [buyButton addTarget:self action:@selector(buyClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buyButton];
        
        /*
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.frame.size.width-50, 10)];
        infoLabel.text = NSLocalizedString(@"PurchasingViewInfo", @"");
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = [Util UIColorForHexColor:@"707a8e"];
        infoLabel.font = [UIFont fontWithName:@"TurkcellSaturaReg" size:10];
        [self addSubview:infoLabel];
         */
    }
    return self;
}

- (void) buyClicked {
    [delegate buyButtonDelegate:self.toActivateOffer];
}

- (NSString *)getPackageDisplayName: (NSString *)roleName {
    NSString *name = @"";
    if ([roleName isEqualToString:@"demo"]) {
        name = NSLocalizedString(@"Welcome", @"");
    } else if ([roleName isEqualToString:@"standard"]) {
        name = @"MINI PAKET";
    } else if ([roleName isEqualToString:@"premium"]) {
        name = @"STANDARD PAKET";
    } else if ([roleName isEqualToString:@"ultimate"]) {
        name = @"MEGA PAKET";
    }
    return name;
}

- (NSString *) quotaCalculator:(float) quota {
    int quotInt = (int)( quota/(1024*1024*1024));
    NSString *quotStr = [NSString stringWithFormat:@"%d",quotInt];
    return quotStr;
    
}
- (void) buyButtonClicked {
    [delegate buyButtonDelegate:toActivateOffer];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

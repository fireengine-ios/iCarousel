//
//  FailurePurchasingView.m
//  Depo
//
//  Created by gurhan on 04/05/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "FailurePurchasingView.h"
#import "Util.h"
#import "SimpleButton.h"

@implementation FailurePurchasingView

@synthesize failedDelegate;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6.0;
        
        if(offer.offerType == OfferTypeTurkcell) {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, 30)];
            offerName.text = [self getPackageDisplayName:offer.role];
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerName.textAlignment = NSTextAlignmentCenter;
//            [self addSubview:offerName];
            
            UILabel *offerQuota = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, self.frame.size.width-40, 25)];
            offerQuota.text = [NSString stringWithFormat:@"%@", [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota]];
            offerQuota.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerQuota.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:20];
            offerQuota.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerQuota];
        } else {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, 30)];
            offerName.text = offer.name;
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerName.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerName];
        }
        
        UILabel *purchasingFailInfo = [[UILabel alloc] initWithFrame:CGRectMake(80, 60, 120,40)];
        purchasingFailInfo.numberOfLines = 0;
        purchasingFailInfo.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:15];
        purchasingFailInfo.backgroundColor = [UIColor clearColor];
        purchasingFailInfo.textColor = [Util UIColorForHexColor:@"363e4e"];
        purchasingFailInfo.textAlignment = NSTextAlignmentCenter;
        purchasingFailInfo.text = NSLocalizedString(@"PurchaseFailure", @"");
        [self addSubview:purchasingFailInfo];
        
        UIImageView *failIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-30,100, 65, 65)];
        failIcon.image = [UIImage imageNamed:@"icon_settings_exclamation.png"];
        failIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:failIcon];
        
        UILabel *infoFailure = [[UILabel alloc] initWithFrame:CGRectMake(30, 170, self.frame.size.width-60, 60)];
        infoFailure.text = NSLocalizedString(@"ErrorPurchasingFailure", @"");
        infoFailure.textAlignment = NSTextAlignmentCenter;
        infoFailure.numberOfLines = 0;
        infoFailure.textColor = [Util UIColorForHexColor:@"707a8e"];
        infoFailure.backgroundColor = [UIColor clearColor];
        infoFailure.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        [self addSubview:infoFailure];
        
        SimpleButton *tryagainButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.frame.size.height-60, self.frame.size.width-40, 50) withTitle:NSLocalizedString(@"TryAgain", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [tryagainButton addTarget:self action:@selector(tryAgainClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tryagainButton];
    }
    return self;
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

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer withError:(NSString *)error {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6.0;
        
        if(offer.offerType == OfferTypeTurkcell) {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, 30)];
            offerName.text = [self getPackageDisplayName:offer.role];
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:30];
            offerName.textAlignment = NSTextAlignmentCenter;
//            [self addSubview:offerName];
            
            UILabel *offerQuota = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.frame.size.width-40, 25)];
            offerQuota.text = [NSString stringWithFormat:@"%@", [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota]];
            offerQuota.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerQuota.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:20];
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
        
        UILabel *purchasingFailInfo = [[UILabel alloc] initWithFrame:CGRectMake(40, 75, self.frame.size.width - 80, 40)];
        purchasingFailInfo.numberOfLines = 0;
        purchasingFailInfo.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:15];
        purchasingFailInfo.backgroundColor = [UIColor clearColor];
        purchasingFailInfo.textColor = [Util UIColorForHexColor:@"363e4e"];
        purchasingFailInfo.textAlignment = NSTextAlignmentCenter;
        purchasingFailInfo.text = NSLocalizedString(@"PurchaseFailure", @"");
        [self addSubview:purchasingFailInfo];
        
        UIImageView *failIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-30,120, 60, 60)];
        failIcon.image = [UIImage imageNamed:@"icon_settings_exclamation.png"];
        failIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:failIcon];
        
        UILabel *infoFailure = [[UILabel alloc] initWithFrame:CGRectMake(30, 185, self.frame.size.width-60, 60)];
        infoFailure.text = error;
        infoFailure.numberOfLines = 0;
        infoFailure.textAlignment = NSTextAlignmentCenter;
        infoFailure.numberOfLines = 0;
        infoFailure.textColor = [Util UIColorForHexColor:@"707a8e"];
        infoFailure.backgroundColor = [UIColor clearColor];
        infoFailure.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        [self addSubview:infoFailure];
        
        UIButton *tryagainButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.frame.size.height-60, self.frame.size.width-40, 50)];
        [tryagainButton setTitle:NSLocalizedString(@"TryAgain", "") forState:UIControlStateNormal];
        [tryagainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tryagainButton addTarget:self action:@selector(tryAgainClicked) forControlEvents:UIControlEventTouchUpInside];
        tryagainButton.backgroundColor = [Util UIColorForHexColor:@"ffe000"];
        tryagainButton.layer.cornerRadius = 5.0;
        [self addSubview:tryagainButton];

    }
    return self;
}

- (NSString *) quotaCalculator:(float) quota {
    int quotInt = (int)( quota/(1024*1024*1024));
    NSString *quotStr = [NSString stringWithFormat:@"%d",quotInt];
    return quotStr;
    
}

- (void) tryAgainClicked {
    [failedDelegate failedActivationTryAgainDelegate];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

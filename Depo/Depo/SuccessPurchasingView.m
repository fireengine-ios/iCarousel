//
//  SuccessPurchasingView.m
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "SuccessPurchasingView.h"
#import "Util.h"
#import "SimpleButton.h"

@implementation SuccessPurchasingView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer {
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6.0;
        
        
        if(offer.offerType == OfferTypeTurkcell) {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, 30)];
            offerName.text = [self getPackageDisplayName:offer.role];
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:25];
            offerName.textAlignment = NSTextAlignmentCenter;
//            [self addSubview:offerName];
            
            UILabel *offerQuota = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, self.frame.size.width-40, 25)];
            offerQuota.text = [NSString stringWithFormat:@"%@", [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota]];
            offerQuota.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerQuota.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:20];
            offerQuota.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerQuota];
        } else {
            UILabel *offerName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, 30)];
            offerName.text = offer.name;
            offerName.textColor = [Util UIColorForHexColor:@"199cd4"];
            offerName.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:25];
            offerName.textAlignment = NSTextAlignmentCenter;
            [self addSubview:offerName];
        }
        
        UILabel *purchasingSuccessInfo = [[UILabel alloc] initWithFrame:CGRectMake(60, 55, 160,35)];
        purchasingSuccessInfo.numberOfLines = 0;
        purchasingSuccessInfo.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        purchasingSuccessInfo.backgroundColor = [UIColor clearColor];
        purchasingSuccessInfo.textColor = [Util UIColorForHexColor:@"363e4e"];
        purchasingSuccessInfo.textAlignment = NSTextAlignmentCenter;
        purchasingSuccessInfo.text = NSLocalizedString(@"SuccessPurchased", @"");
        [self addSubview:purchasingSuccessInfo];
        
        UIImageView *successIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-30, 100, 60, 60)];
        successIcon.image = [UIImage imageNamed:@"icon_settings_tick.png"];
        successIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:successIcon];
        
        UILabel *infoSuccess = [[UILabel alloc] initWithFrame:CGRectMake(30, 170, self.frame.size.width-60, 60)];
        if(offer.offerType == OfferTypeTurkcell) {
            infoSuccess.text = NSLocalizedString(@"PurchasingViewSuccessInfo", @"");
        } else {
            infoSuccess.text = NSLocalizedString(@"PurchasingViewSuccessInfoIAP", @"");
        }
        infoSuccess.textAlignment = NSTextAlignmentCenter;
        infoSuccess.numberOfLines = 0;
        infoSuccess.textColor = [Util UIColorForHexColor:@"707a8e"];
        infoSuccess.backgroundColor = [UIColor clearColor];
        infoSuccess.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:14];
        [self addSubview:infoSuccess];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.frame.size.height-60, self.frame.size.width-40, 50) withTitle:NSLocalizedString(@"OK", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(okClicked) forControlEvents:UIControlEventTouchUpInside];
        okButton.isAccessibilityElement = YES;
        okButton.accessibilityIdentifier = @"okButtonSuccessPurchasing";
        [self addSubview:okButton];
    }
    return self;
}

- (void) okClicked {
    [delegate okButtonDelegate];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

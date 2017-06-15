//
//  RevisitedCurrentSubscriptionCell.m
//  Depo
//
//  Created by Mahir on 14/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedCurrentSubscriptionCell.h"
#import "SimpleButton.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppUtil.h"

@implementation RevisitedCurrentSubscriptionCell

@synthesize delegate;
@synthesize subscription;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSubscription:(Subscription *)_subscription {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundColor = [UIColor clearColor];
        self.subscription = _subscription;

        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 105)];
        infoView.backgroundColor = [UIColor whiteColor];
        [self addSubview:infoView];
        
        NSString *topInfo = @"";

        float topYIndex = 15;

        if([subscription.plan.type isEqualToString:@"LIFECELL"]) {
            topInfo = subscription.plan.displayName;
        } else {
            if([subscription.plan.name isEqualToString:@"demo"]) {
                topYIndex = 23;
                topInfo = [NSString stringWithFormat:NSLocalizedString(@"WelcomePackageName", @""), [Util transformedHugeSizeValueDecimalIfNecessary:subscription.plan.quota]];
            } else {
                topInfo = [NSString stringWithFormat:@"%@ %.2f TL/%@", [Util transformedHugeSizeValueDecimalIfNecessary:subscription.plan.quota], subscription.plan.price, [subscription.plan.period isEqualToString:@"MONTH"] ? NSLocalizedString(@"MonthlyShort", "") : NSLocalizedString(@"YearlyShort", "")];
            }
        }

        CustomLabel *topLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topYIndex, infoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"555555"] withText:topInfo withAlignment:NSTextAlignmentCenter];
        [infoView addSubview:topLabel];
        
        topYIndex += 20;

        if(subscription.nextRenewalDate) {
            NSString *bottomInfo = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"RenewalDate", @""), subscription.nextRenewalDate ? subscription.nextRenewalDate : @""];
            CustomLabel *bottomLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topYIndex, infoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:bottomInfo withAlignment:NSTextAlignmentCenter];
            [infoView addSubview:bottomLabel];
            
            topYIndex += 22;
        }

        if(![subscription.plan.role isEqualToString:@"demo"]){
            SimpleButton *cancelButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, topYIndex, infoView.frame.size.width, 20) withTitle:NSLocalizedString(@"CancelSubscription", @"") withTitleColor:[Util UIColorForHexColor:@"3fb0e8"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] isUnderline:YES withUnderlineColor:[Util UIColorForHexColor:@"3fb0e8"]];
            [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
            
            topYIndex += 28;

            NSString *linkTitle = @"turkcell.com.tr";
            if([subscription.plan.type isEqualToString:@"LIFECELL"]) {
                linkTitle = @"lifecell.com.ua";
            }
            else if([subscription.plan.type isEqualToString:@"KKTCELL"]) {
                linkTitle = @"";
            }
            if(subscription.type) {
                if([subscription.type isEqualToString:@"INAPP_PURCHASE_GOOGLE"]) {
                    linkTitle = @"googleplay";
                } else if([subscription.type isEqualToString:@"INAPP_PURCHASE_APPLE"]) {
                    linkTitle = @"applestore";
                }
            }
            SimpleButton *linkButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, topYIndex, infoView.frame.size.width, 20) withTitle:linkTitle withTitleColor:[Util UIColorForHexColor:@"555555"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] isUnderline:NO withUnderlineColor:[Util UIColorForHexColor:@"555555"]];
            [linkButton addTarget:self action:@selector(linkClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:linkButton];
        }
    }
    return self;
}

- (void) cancelClicked {
    [delegate revisitedCurrentSubscriptionCellDidSelectCancelForSubscription:self.subscription];
}

- (void) linkClicked {
    [delegate revisitedCurrentSubscriptionCellDidSelectLinkForSubscription:self.subscription];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

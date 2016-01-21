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

        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 86)];
        infoView.backgroundColor = [UIColor whiteColor];
        [self addSubview:infoView];
        
        NSString *topInfo = [NSString stringWithFormat:@"%@ (%@) %.1f TL/%@", subscription.plan.displayName, [Util transformedHugeSizeValueDecimalIfNecessary:subscription.plan.quota], subscription.plan.price, [subscription.plan.period isEqualToString:@"MONTH"] ? NSLocalizedString(@"MonthlyShort", "") : NSLocalizedString(@"YearlyShort", "")];
        NSString *bottomInfo = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"RenewalDate", @""), subscription.nextRenewalDate ? subscription.nextRenewalDate : @""];

        CustomLabel *topLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 23, infoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"555555"] withText:topInfo withAlignment:NSTextAlignmentCenter];
        [infoView addSubview:topLabel];

        CustomLabel *bottomLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 43, infoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:bottomInfo withAlignment:NSTextAlignmentCenter];
        [infoView addSubview:bottomLabel];

        SimpleButton *cancelButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, infoView.frame.origin.y + infoView.frame.size.height + 14, infoView.frame.size.width, 20) withTitle:NSLocalizedString(@"CancelSubscription", @"") withTitleColor:[Util UIColorForHexColor:@"3fb0e8"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] isUnderline:YES withUnderlineColor:[Util UIColorForHexColor:@"3fb0e8"]];
        [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
    }
    return self;
}

- (void) cancelClicked {
    [delegate revisitedCurrentSubscriptionCellDidSelectCancelForSubscription:self.subscription];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

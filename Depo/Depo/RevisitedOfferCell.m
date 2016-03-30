//
//  RevisitedOfferCell.m
//  Depo
//
//  Created by Mahir on 14/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedOfferCell.h"
#import "SimpleButton.h"
#import "Util.h"
#import "AppUtil.h"
#import "MPush.h"

@implementation RevisitedOfferCell

@synthesize delegate;
@synthesize offer;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(Offer *) _offer {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor whiteColor];
        self.offer = _offer;
        
        NSString *periodInfoKey = [NSString stringWithFormat:@"PERIOD_%@_SHORT", offer.period];
        NSString *periodInfo = NSLocalizedString(periodInfoKey, "");

        NSString *buttonTitle = [NSString stringWithFormat:@"%@ %@ TL/%@", [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota], offer.price, [offer.period isEqualToString:@"MONTH"] ? NSLocalizedString(@"MonthlyShort", "") : NSLocalizedString(@"YearlyShort", "")];
        if(offer.offerType == OfferTypeApple) {
            buttonTitle = [NSString stringWithFormat:@"%@ %@ /%@", offer.name, offer.price, periodInfo];
        }

        SimpleButton *buyButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 50) withTitle:buttonTitle withTitleColor:[Util UIColorForHexColor:@"555555"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:4 adjustFont:YES];
        [buyButton addTarget:self action:@selector(buyClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buyButton];
    }
    return self;
}

- (void) buyClicked {
    NSString *formattedQuotaString = [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota];
    NSString *tagName = nil;
    if([formattedQuotaString isEqualToString:@"50 GB"]) {
        tagName = @"50_gb_button_clicked";
    } else if([formattedQuotaString isEqualToString:@"500 GB"]) {
        tagName = @"500_gb_button_clicked";
    } else if([formattedQuotaString isEqualToString:@"2.5 TB"]) {
        tagName = @"2_5_tb_button_clicked";
    }
    if(tagName) {
        [MPush hitTag:tagName];
        [MPush hitEvent:tagName];
    }
    
    [delegate revisitedOfferCellDelegateDidClickBuy:self.offer];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

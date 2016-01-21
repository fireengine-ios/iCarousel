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

@implementation RevisitedOfferCell

@synthesize delegate;
@synthesize offer;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(Offer *) _offer {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor whiteColor];
        self.offer = _offer;
        
        NSString *buttonTitle = [NSString stringWithFormat:@"%@ (%@) %@ TL/%@", offer.role ? [AppUtil getPackageDisplayName:offer.role] : offer.name, [Util transformedHugeSizeValueDecimalIfNecessary:offer.quota], offer.price, [offer.period isEqualToString:@"MONTH"] ? NSLocalizedString(@"MonthlyShort", "") : NSLocalizedString(@"YearlyShort", "")];

        SimpleButton *buyButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 50) withTitle:buttonTitle withTitleColor:[Util UIColorForHexColor:@"555555"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:4 adjustFont:YES];
        [buyButton addTarget:self action:@selector(buyClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buyButton];
    }
    return self;
}

- (void) buyClicked {
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

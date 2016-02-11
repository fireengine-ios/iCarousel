//
//  OfferRedesignCell.m
//  Depo
//
//  Created by gurhan on 28/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "OfferRedesignCell.h"
#import "Util.h"
#import "AppDelegate.h"

@implementation OfferRedesignCell

@synthesize offerCellDel;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(OfferContainer *)offer {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        int quotaInt = (int) (offer.quota/(1024*1024*1024));
        NSString *quotaConvertToString = [NSString stringWithFormat:@"%d",quotaInt];
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        int width = [Util calculateWidthForText:quotaConvertToString forHeight:40 forFont:font]+2;
        UILabel *quotaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, width, 40)];
        quotaLabel.text = quotaConvertToString;
        quotaLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        quotaLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaLabel];
        
        UILabel *quotaGBLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+quotaLabel.frame.size.width, 30, 50, 25)];
        quotaGBLabel.text = @"GB";
        quotaGBLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:25];
        quotaGBLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaGBLabel];
        
        UILabel *offerDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60,120 , 20)];
        offerDescriptionLabel.text = [self roleTranslator:offer.montlyOffer.role?offer.montlyOffer.role:offer.yearlyOffer.role];
        offerDescriptionLabel.textColor = [Util UIColorForHexColor:@"999999"];
        offerDescriptionLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
        [self addSubview:offerDescriptionLabel];
        
        UILabel *yearAvantage = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 5, self.frame.size.width/2-20, 9)];
        yearAvantage.text = @"Aylığa göre %20 daha ucuz";
        yearAvantage.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:9];
        yearAvantage.textColor = [Util UIColorForHexColor:@"6bd554"];
        yearAvantage.backgroundColor = [UIColor clearColor];
        yearAvantage.textAlignment = NSTextAlignmentCenter;
        [self addSubview:yearAvantage];
        
        OfferRectangleView *offerRectangleYear = [[OfferRectangleView alloc] initWithFrame:CGRectMake(self.frame.size.width/2,15 , self.frame.size.width/2-20, 30) withOffer:offer.yearlyOffer withColor:@"fede32"];
        offerRectangleYear.delegate = self;
        [self addSubview:offerRectangleYear];
        
        OfferRectangleView *offerRectangleMonth = [[OfferRectangleView alloc] initWithRoundedFrame:CGRectMake(self.frame.size.width/2, 50, self.frame.size.width/2-20, 30) withOffer:offer.montlyOffer withColor:@"fede32"];
        offerRectangleMonth.delegate = self;
        [self addSubview:offerRectangleMonth];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCurrenSubscription:(Subscription *)curentSubscription {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //int quotaInt = (int) (curentSubscription.plan.quota/(1024*1024*1024));
        NSString *quotaConvertToString = [NSString stringWithFormat:@"%@",[Util transformedHugeSizeValueDecimalIfNecessary:APPDELEGATE.session.usage.totalStorage]];
        NSArray *quotaInfo = [self getQuotaInfoStrings:quotaConvertToString];
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        int width = [Util calculateWidthForText:[quotaInfo objectAtIndex:0] forHeight:40 forFont:font]+2;

        UILabel *quotaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, width, 40)];
        quotaLabel.text = [quotaInfo objectAtIndex:0];
        quotaLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        quotaLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaLabel];

        UILabel *quotaGBLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+quotaLabel.frame.size.width, 25, 50, 25)];
        quotaGBLabel.text = [quotaInfo objectAtIndex:1];
        quotaGBLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:25];
        quotaGBLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaGBLabel];

        int descWidth = [Util calculateWidthForText:[self roleTranslator:curentSubscription.plan.displayName] forHeight:20 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20]]+2;
        UILabel *offerDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55,descWidth , 20)];
        offerDescriptionLabel.text = [self roleTranslator:curentSubscription.plan.role];
        offerDescriptionLabel.textColor = [Util UIColorForHexColor:@"999999"];
        offerDescriptionLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
        [self addSubview:offerDescriptionLabel];
        
        if ([curentSubscription.plan.name isEqualToString:@"demo"]) {
            int infoWidth = [Util calculateWidthForText:@"ÜCRETSİZ" forHeight:25 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18]]+2;
            UILabel *infoSubscriton = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2+20, 30,infoWidth , 25)];
            infoSubscriton.textAlignment = NSTextAlignmentCenter;
            infoSubscriton.text = NSLocalizedString(@"SubscriptionFree", "");
            infoSubscriton.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:18];
            infoSubscriton.backgroundColor = [UIColor clearColor];
            infoSubscriton.textColor = [Util UIColorForHexColor:@"999999"];
            [self addSubview:infoSubscriton];
        }
        else {
            UILabel *subscriptionDesc = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 5, self.frame.size.width/2-20, 15)];
            if(curentSubscription.plan.price > 0.0f) {
                subscriptionDesc.text = [NSString stringWithFormat:@"%@ %.2f TL",[self getOfferPeriodString:curentSubscription.plan.period],curentSubscription.plan.price];
            } else {
                subscriptionDesc.text = NSLocalizedString(@"SubscriptionFree", @"");
            }
            subscriptionDesc.textAlignment = NSTextAlignmentCenter;
            subscriptionDesc.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
            subscriptionDesc.backgroundColor = [UIColor clearColor];
            subscriptionDesc.textColor = [Util UIColorForHexColor:@"199cd4"];
            [self addSubview:subscriptionDesc];
            
            UILabel *longSubscriptionDesc = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 20, self.frame.size.width/2-20, 55)];
            longSubscriptionDesc.numberOfLines = 0;
            longSubscriptionDesc.lineBreakMode = NSLineBreakByWordWrapping;
            NSString *cancelKeyword = [self getNameForSms:curentSubscription];
            if([cancelKeyword isEqualToString:@""]) {
                longSubscriptionDesc.text = @"";
            } else {
                longSubscriptionDesc.text = [NSString stringWithFormat:NSLocalizedString(@"SubscriptionLongInfo", ""), [self getNameForSms:curentSubscription]];
            }
            longSubscriptionDesc.textColor = [Util UIColorForHexColor:@"999999"];
            longSubscriptionDesc.textAlignment = NSTextAlignmentCenter;
            longSubscriptionDesc.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:12];
            longSubscriptionDesc.backgroundColor = [UIColor clearColor];
            [self addSubview:longSubscriptionDesc];
            
        }

    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(OfferContainer *)offerContainer withCurrentSubscription:(Subscription *)currentSubscription {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //int quotaInt = (int) (offerContainer.quota/(1024*1024*1024));
        NSString *quotaConvertToString = [NSString stringWithFormat:@"%@",[Util transformedHugeSizeValueDecimalIfNecessary:offerContainer.quota]];
        NSArray *quotaArr = [self getQuotaInfoStrings:quotaConvertToString];
        //NSString *quotaConvertToString = [NSString stringWithFormat:@"%d",quotaInt];
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        int width = [Util calculateWidthForText:[quotaArr objectAtIndex:0] forHeight:40 forFont:font]+2;
        
        UILabel *quotaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, width, 40)];
        quotaLabel.text = [quotaArr objectAtIndex:0];
        quotaLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:40];
        quotaLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaLabel];
        
        UILabel *quotaGBLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+quotaLabel.frame.size.width, 25, 50, 25)];
        quotaGBLabel.text = [quotaArr objectAtIndex:1];
        quotaGBLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:25];
        quotaGBLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [self addSubview:quotaGBLabel];
        
        UILabel *offerDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 120, 20)];
        offerDescriptionLabel.text = [self roleTranslator:offerContainer.montlyOffer.role?offerContainer.montlyOffer.role:offerContainer.yearlyOffer.role];
        offerDescriptionLabel.textColor = [Util UIColorForHexColor:@"999999"];
        offerDescriptionLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
        [self addSubview:offerDescriptionLabel];
        
        if (!offerContainer.montlyOffer) {
            if (offerContainer.quota >currentSubscription.plan.quota) {
                
                OfferRectangleView *offerRectangleYear = [[OfferRectangleView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 25, self.frame.size.width/2-20, 40) withOffer:offerContainer.yearlyOffer withColor:@"fede32"];
                offerRectangleYear.delegate = self;
                [self addSubview:offerRectangleYear];

            }
            else {
                OfferRectangleView *offerRectangleYear = [[OfferRectangleView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 25, self.frame.size.width/2-20, 40) withOffer:offerContainer.yearlyOffer withColor:@"cfd3dc"];
                offerRectangleYear.delegate = self;
                [self addSubview:offerRectangleYear];

            }
        }
        else if(!offerContainer.yearlyOffer) {
            if (offerContainer.quota >currentSubscription.plan.quota) {
                OfferRectangleView *offerRectangleMonth = [[OfferRectangleView alloc] initWithRoundedFrame:CGRectMake(self.frame.size.width/2, 25, self.frame.size.width/2-20, 40) withOffer:offerContainer.montlyOffer withColor:@"fede32"];
                offerRectangleMonth.delegate = self;
                [self addSubview:offerRectangleMonth];
                
            }
            else {
                OfferRectangleView *offerRectangleMonth = [[OfferRectangleView alloc]  initWithRoundedFrame:CGRectMake(self.frame.size.width/2, 25, self.frame.size.width/2-20, 40) withOffer:offerContainer.montlyOffer withColor:@"cfd3dc"];
                offerRectangleMonth.delegate = self;
                [self addSubview:offerRectangleMonth];
                
            }

        }
        else if (offerContainer.montlyOffer && offerContainer.yearlyOffer) {
            if (currentSubscription.plan.quota > offerContainer.quota) {
                [self drawCampaignText];
                OfferRectangleView *offerRectangleYear = [[OfferRectangleView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 15, self.frame.size.width/2-20, 30) withOffer:offerContainer.yearlyOffer withColor:@"cfd3dc"];
                offerRectangleYear.delegate = self;
                [self addSubview:offerRectangleYear];
                
                OfferRectangleView *offerRectangleMonth = [[OfferRectangleView alloc] initWithRoundedFrame:CGRectMake(self.frame.size.width/2, 50, self.frame.size.width/2-20, 30) withOffer:offerContainer.montlyOffer withColor:@"cfd3dc"];
                offerRectangleMonth.delegate = self;
                [self addSubview:offerRectangleMonth];
            }
            else {
                OfferRectangleView *offerRectangleYear = [[OfferRectangleView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 15, self.frame.size.width/2-20, 30) withOffer:offerContainer.yearlyOffer withColor:@"fede32"];
                offerRectangleYear.delegate = self;
                [self addSubview:offerRectangleYear];
                
                OfferRectangleView *offerRectangleMonth = [[OfferRectangleView alloc] initWithRoundedFrame:CGRectMake(self.frame.size.width/2, 50, self.frame.size.width/2-20, 30) withOffer:offerContainer.montlyOffer withColor:@"fede32"];
                offerRectangleMonth.delegate = self;
                [self addSubview:offerRectangleMonth];
            }
            

        }

        UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 89, 320, 1)];
        greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
        [self addSubview:greyLine];

    }
    return self;
}

- (void) drawCampaignText{
    UILabel *yearAvantage = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 5, self.frame.size.width/2-20, 9)];
    yearAvantage.text = @"Aylığa göre %20 daha ucuz";
    yearAvantage.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:9];
    yearAvantage.textColor = [Util UIColorForHexColor:@"6bd554"];
    yearAvantage.backgroundColor = [UIColor clearColor];
    yearAvantage.textAlignment = NSTextAlignmentCenter;
    [self addSubview:yearAvantage];

}


- (NSString *) roleTranslator:(NSString *) role {
    if ([role isEqualToString:@"premium"]) {
        return @"Standart Paket";
    }
    else if([role isEqualToString:@"ultimate"]) {
        return @"Mega Paket";
    }
    else if ([role isEqualToString:@"standard"]) {
        return @"Mini Paket";
    }
    else
        return @"Hoşgeldin Paketi";
    
}

- (NSArray *) getQuotaInfoStrings :(NSString *) quotaString {
    NSString* result = [quotaString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *array = [result componentsSeparatedByString:@" "];
    return array;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (NSString *) getOfferPeriodString :(NSString *) period {
    NSString *strKey = [NSString stringWithFormat:@"PERIOD_%@", period];
    return NSLocalizedString(strKey, "");
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

-(void) purchaseOffer:(Offer *)offer {
    [offerCellDel selectedOfferPurchase:offer];
}

- (NSString *)getNameForSms: (Subscription *) currentSubscription {
    NSString *name = @"";
    if ([currentSubscription.plan.role isEqualToString:@"standard"]) {
        name = @"MINIDEPO";
    } else if ([currentSubscription.plan.role isEqualToString:@"premium"]) {
        name = @"STANDARTDEPO";
    } else if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
        name = @"MEGADEPO";
    }
    return name;
}

@end

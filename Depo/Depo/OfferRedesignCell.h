//
//  OfferRedesignCell.h
//  Depo
//
//  Created by gurhan on 28/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"
#import "Subscription.h"
#import "OfferRectangleView.h"
#import "OfferContainer.h"

@protocol OfferReDesignCellDelegate <NSObject>
- (void) selectedOfferPurchase:(Offer *) offer;
@end

@interface OfferRedesignCell : UITableViewCell <PurchaseOfferDelegate>

@property (nonatomic,strong) id<OfferReDesignCellDelegate> offerCellDel;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer: (OfferContainer *) offer;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCurrenSubscription:(Subscription *) curentSubscription;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(OfferContainer *) offerContainer withCurrentSubscription:(Subscription *) currentSubscription;

@end

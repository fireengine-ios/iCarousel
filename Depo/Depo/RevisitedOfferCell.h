//
//  RevisitedOfferCell.h
//  Depo
//
//  Created by Mahir on 14/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

@protocol RevisitedOfferCellDelegate <NSObject>
- (void) revisitedOfferCellDelegateDidClickBuy:(Offer *) offerRef;
@end

@interface RevisitedOfferCell : UITableViewCell

@property (nonatomic, weak) id<RevisitedOfferCellDelegate> delegate;
@property (nonatomic, strong) Offer *offer;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withOffer:(Offer *) _offer;

@end

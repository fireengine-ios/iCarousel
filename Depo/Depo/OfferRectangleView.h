//
//  OfferRectangleView.h
//  Depo
//
//  Created by gurhan on 28/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"
#import "OfferContainer.h"

@protocol PurchaseOfferDelegate <NSObject>

- (void) purchaseOffer:(Offer *) offer;

@end

@interface OfferRectangleView : UIView

@property (nonatomic,strong) id<PurchaseOfferDelegate> delegate;
@property (nonatomic,strong) Offer *selectedOffer;
@property (nonatomic,strong) UIButton *buyButton;
@property (nonatomic,strong) UIButton *buyMonthlyButton;

- (id) initWithRoundedFrame:(CGRect)frame withOffer: (Offer *) offer withColor:(NSString *) colorCode ;
- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer withColor:(NSString *)colorCode;

@end

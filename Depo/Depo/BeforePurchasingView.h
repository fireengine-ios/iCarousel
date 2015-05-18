//
//  BeforePurchasingView.h
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

@protocol BeforePurchasingViewDelegate <NSObject>
- (void) buyButtonDelegate:(Offer *) offer;
@end

@interface BeforePurchasingView : UIView

@property (strong,nonatomic) id<BeforePurchasingViewDelegate> delegate;
@property (strong,nonatomic) Offer *toActivateOffer;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *) offer;

@end

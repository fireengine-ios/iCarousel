//
//  SuccessPurchasingView.h
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

@protocol SuccessPurchasingViewDelegate <NSObject>

- (void) okButtonDelegate;

@end

@interface SuccessPurchasingView : UIView

@property (strong,nonatomic) id<SuccessPurchasingViewDelegate> delegate;


- (id) initWithFrame:(CGRect)frame withOffer: (Offer *) offer;

@end

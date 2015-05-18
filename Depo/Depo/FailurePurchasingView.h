//
//  FailurePurchasingView.h
//  Depo
//
//  Created by gurhan on 04/05/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

@protocol FailurePurchaseDelegate <NSObject>

- (void) failedActivationTryAgainDelegate;

@end

@interface FailurePurchasingView : UIView

@property (strong,nonatomic) id<FailurePurchaseDelegate> failedDelegate;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *) offer;
- (id) initWithFrame:(CGRect)frame withOffer:(Offer *) offer withError:(NSString *) error;

@end

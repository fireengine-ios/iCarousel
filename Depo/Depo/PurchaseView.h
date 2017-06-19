//
//  PurchaseView.h
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"
#import "BeforePurchasingView.h"
#import "SuccessPurchasingView.h"
#import "BeforePurchasingView.h"
#import "FailurePurchasingView.h"


@protocol PurchaseViewDelegate <NSObject>
- (void) shouldCloseView;
- (void) activatePurchasing:(Offer *) chosenOffer;
- (void) failedPurchaseTryAgainDelegate;
- (void) purchasingDone;
@end

@interface PurchaseView : UIView <BeforePurchasingViewDelegate,SuccessPurchasingViewDelegate,FailurePurchaseDelegate>

@property (nonatomic,strong) id<PurchaseViewDelegate> delegate;
@property (nonatomic,strong) Offer *toBuyOffer;
@property (strong,nonatomic) BeforePurchasingView *beforeDialog;
@property (strong,nonatomic) SuccessPurchasingView *successDialog;
@property (strong,nonatomic) FailurePurchasingView *failDialog;


- (id) initWithFrame:(CGRect)frame withOffer:(Offer *) offer;
- (void) drawBeforePurchaseView ;
- (void) drawSuccessPurchaseView ;
- (void) drawFailedPurchaseView:(NSString *) error ;

@end

//
//  PurchaseView.m
//  Depo
//
//  Created by gurhan on 30/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "PurchaseView.h"

@implementation PurchaseView

@synthesize delegate;
@synthesize toBuyOffer;
@synthesize beforeDialog;
@synthesize successDialog;
@synthesize failDialog;

- (id) initWithFrame:(CGRect)frame withOffer:(Offer *)offer {
    if (self = [super initWithFrame:frame]) {
        
        self.toBuyOffer = offer;
        UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        innerView.alpha = 0.8;
        innerView.userInteractionEnabled = YES;
        innerView.backgroundColor = [UIColor blackColor];
        [self addSubview:innerView];
        
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] init];
        [closeTap addTarget:self action:@selector(closePurchasingView)];
        [innerView addGestureRecognizer:closeTap];
        
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 86, 20, 20)];
        [closeButton setImage:[UIImage imageNamed:@"icon_settings_dialog_close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closePurchasingView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        
    }
    return self;
}

- (void) closePurchasingView {
    [delegate shouldCloseView];
}

- (void) buyButtonDelegate {
    [delegate activatePurchasing:toBuyOffer];
}

- (void) drawSuccessPurchaseView {
    [self.beforeDialog setHidden:YES];
    successDialog = [[SuccessPurchasingView alloc] initWithFrame:CGRectMake(20, 110, self.frame.size.width-40, 300) withOffer:toBuyOffer];
    successDialog.delegate = self;
    [self addSubview:successDialog];

}

- (void) drawFailedPurchaseView:(NSString *) error{
    [self.beforeDialog setHidden:YES];
    failDialog = [[FailurePurchasingView alloc] initWithFrame:CGRectMake(20, 130, self.frame.size.width-40, 290) withOffer:toBuyOffer withError:error];
    [self addSubview:failDialog];
    
}

- (void) drawBeforePurchaseView {
    beforeDialog = [[BeforePurchasingView alloc] initWithFrame:CGRectMake(20, 130, self.frame.size.width-40, 230) withOffer:toBuyOffer];
    beforeDialog.delegate = self;
    [self addSubview:beforeDialog];

}

- (void) activatePurchasing:(Offer *)offer {
    [delegate activatePurchasing:toBuyOffer];
}

- (void) okButtonDelegate {
    [delegate purchasingDone];
}

- (void) failedActivationTryAgain {
    [self failedPurchaseTryAgainDelegate];
}

- (void) buyButtonDelegate:(Offer *)offer {
    [delegate activatePurchasing:toBuyOffer];
}

- (void) failedActivationTryAgainDelegate {
}

- (void) failedPurchaseTryAgainDelegate {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

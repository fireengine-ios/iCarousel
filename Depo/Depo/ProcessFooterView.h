//
//  ProcessFooterView.h
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@protocol ProcessFooterDelegate <NSObject>
- (void) processFooterShouldDismissWithButtonKey:(NSString *) postButtonKeyVal;
@end

@interface ProcessFooterView : UIView {
    UIImageView *indicator;
    UIImageView *successImgView;
    UIImageView *failImgView;
    UIActivityIndicatorView *defaultIndicator;
    CustomLabel *messageLabel;
    BOOL isAnimating;
    BOOL processConcluded;
}

@property (nonatomic, weak) id<ProcessFooterDelegate> delegate;
@property (nonatomic, strong) NSString *processMsg;
@property (nonatomic, strong) NSString *successMsg;
@property (nonatomic, strong) NSString *failMsg;
@property (nonatomic, strong) NSString *postButtonKey;

- (id)initWithFrame:(CGRect)frame withProcessMessage:(NSString *) _processMsg withFinalMessage:(NSString *) _successMsg withFailMessage:(NSString *) _failMsg;
- (void) startLoading;
- (void) startLoadingAndHideAfterSeconds:(int)seconds;
- (void) showMessageForSuccess;
- (void) showMessageForSuccessWithPostButtonKey:(NSString *) buttonKey;
- (void) showMessageForFailure;
- (void) showMessageForFailureWithPostButtonKey:(NSString *) buttonKey;

-(void)updateMessage:(NSString *)message isSuccess:(BOOL)success;
-(void)showWithLoadingMessage:(NSString *)message;

- (void) dismissWithSuccessMessage;
- (void) dismissWithFailureMessage;

@end

//
//  ProcessFooterView.h
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface ProcessFooterView : UIView {
    UIImageView *indicator;
    UIImageView *successImgView;
    UIActivityIndicatorView *defaultIndicator;
    CustomLabel *messageLabel;
    BOOL isAnimating;
}

@property (nonatomic, strong) NSString *processMsg;
@property (nonatomic, strong) NSString *successMsg;
@property (nonatomic, strong) NSString *failMsg;

- (id)initWithFrame:(CGRect)frame withProcessMessage:(NSString *) _processMsg withFinalMessage:(NSString *) _successMsg withFailMessage:(NSString *) _failMsg;
- (void) startLoading;
- (void) showMessageForSuccess;
- (void) showMessageForFailure;

@end

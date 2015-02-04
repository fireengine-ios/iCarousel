//
//  ProcessFooterView.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ProcessFooterView.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProcessFooterView

@synthesize delegate;
@synthesize processMsg;
@synthesize successMsg;
@synthesize failMsg;
@synthesize postButtonKey;

- (id)initWithFrame:(CGRect)frame withProcessMessage:(NSString *) _processMsg withFinalMessage:(NSString *) _successMsg withFailMessage:(NSString *) _failMsg {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];

        self.processMsg = _processMsg;
        self.successMsg = _successMsg;
        self.failMsg = _failMsg;
        
        UIImage *indicatorImg = [UIImage imageNamed:@"action_bar_preloader.png"];
        indicator = [[UIImageView alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - indicatorImg.size.height)/2, indicatorImg.size.width, indicatorImg.size.height)];
        indicator.image = indicatorImg;
//        [self addSubview:indicator];
        
        defaultIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        defaultIndicator.center = indicator.center;
        [self addSubview:defaultIndicator];
        
        successImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_icon.png"]];
        successImgView.frame = CGRectMake(20, (self.frame.size.height - 11)/2, 14, 11);
        successImgView.center = indicator.center;
        successImgView.hidden = YES;
        [self addSubview:successImgView];
        
        messageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, (self.frame.size.height - 20)/2, self.frame.size.width - 70, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:17] withColor:[UIColor whiteColor] withText:@""];
        [self addSubview:messageLabel];
        
        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageClicked)];
        [self addGestureRecognizer:singleTapGesture];
    }
    return self;
}

- (void) startLoading {
    messageLabel.text = self.processMsg;
    
    [defaultIndicator startAnimating];
    /*
    if (!isAnimating) {
        isAnimating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
     */
}

- (void) messageClicked {
    if(processConcluded) {
        [delegate processFooterShouldDismissWithButtonKey:self.postButtonKey];
        [self removeFromSuperview];
    }
}

- (void) showMessageForSuccess {
    [self showMessageForSuccessWithPostButtonKey:nil];
}

- (void) showMessageForSuccessWithPostButtonKey:(NSString *) buttonKey {
    self.postButtonKey = buttonKey;
    processConcluded = YES;
    messageLabel.text = self.successMsg;
//    isAnimating = NO;
//    indicator.hidden = YES;
    [defaultIndicator stopAnimating];
    defaultIndicator.hidden = YES;
    successImgView.hidden = NO;
//    [self performSelector:@selector(dismissAfterDelay) withObject:nil afterDelay:1.2f];
}

- (void) showMessageForFailure {
    [self showMessageForFailureWithPostButtonKey:nil];
}

- (void) showMessageForFailureWithPostButtonKey:(NSString *) buttonKey {
    self.postButtonKey = buttonKey;
    processConcluded = YES;
    messageLabel.text = self.failMsg;
//    isAnimating = NO;
//    indicator.hidden = YES;
    [defaultIndicator stopAnimating];
    defaultIndicator.hidden = YES;
//    [self performSelector:@selector(dismissAfterDelay) withObject:nil afterDelay:1.2f];
}

- (void) dismissAfterDelay {
    [self removeFromSuperview];
}

- (void) stopLoading {
    isAnimating = NO;
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.15f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         indicator.transform = CGAffineTransformRotate(indicator.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (isAnimating) {
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

    /*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

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

@synthesize processMsg;
@synthesize successMsg;
@synthesize failMsg;

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
        
        messageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, (self.frame.size.height - 20)/2, self.frame.size.width - 70, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:17] withColor:[UIColor whiteColor] withText:@""];
        [self addSubview:messageLabel];
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

- (void) showMessageForSuccess {
    messageLabel.text = self.successMsg;
//    isAnimating = NO;
//    indicator.hidden = YES;
    [defaultIndicator stopAnimating];
    defaultIndicator.hidden = YES;
}

- (void) showMessageForFailure {
    messageLabel.text = self.failMsg;
//    isAnimating = NO;
//    indicator.hidden = YES;
    [defaultIndicator stopAnimating];
    defaultIndicator.hidden = YES;
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

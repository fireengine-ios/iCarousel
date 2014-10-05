//
//  FloatingAddButton.m
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FloatingAddButton.h"
#import "AppConstants.h"

@implementation FloatingAddButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageNamed:@"big_plus_icon.png"] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) buttonClicked {
    if(!isActive) {
        double rads = DEGREES_TO_RADIANS(45);
        [self setImage:[UIImage imageNamed:@"big_plus_icon.png"] forState:UIControlStateNormal];
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:0
                         animations:^{
                             self.transform = transform;
                         }
                         completion:^(BOOL finished) {
                             [self setImage:[UIImage imageNamed:@"yellow_close_button.png"] forState:UIControlStateNormal];
                             self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                             isActive = !isActive;
                         }];
        [delegate floatingAddButtonDidOpenMenu];
    } else {
        [self setImage:[UIImage imageNamed:@"big_plus_icon.png"] forState:UIControlStateNormal];
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(45));

        double rads = DEGREES_TO_RADIANS(0);
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:0
                         animations:^{
                             self.transform = transform;
                         }
                         completion:^(BOOL finished) {
                             isActive = !isActive;
                         }];
        [delegate floatingAddButtonDidCloseMenu];
    }
}

- (void) immediateReset {
    [self setImage:[UIImage imageNamed:@"big_plus_icon.png"] forState:UIControlStateNormal];
    double rads = DEGREES_TO_RADIANS(0);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.transform = transform;
    isActive = NO;
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

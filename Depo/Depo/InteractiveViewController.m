//
//  InteractiveViewController.m
//  SwipeToDismiss
//
//  Created by Ömer Burak Kır on 2/24/17.
//  Copyright © 2017 Ömer Burak Kır. All rights reserved.
//

#import "InteractiveViewController.h"

@interface InteractiveViewController () <UIGestureRecognizerDelegate>

@end

@implementation InteractiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.window != nil) {
        [self dismissWindowAnimated:flag completion:completion];
    }
    else {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

- (void)dismissWindowAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (flag) {
        [self dismissWindowDirection:DismissDirectionBottom
                          completion:completion];
    } else {
        self.window.rootViewController = nil;
        self.window = nil;
        [[UIApplication sharedApplication].windows.firstObject makeKeyAndVisible];
        if (completion) {
            completion();
        }
    }
}

- (void)dismissWindowDirection:(DismissDirection)direction completion:(void (^)(void))completion {
    
    switch (direction) {
    case DismissDirectionTop:
            self.topConstraint.constant = -self.view.bounds.size.height;
            break;
    default:
            self.topConstraint.constant = self.view.bounds.size.height;
            break;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.window.backgroundColor = [UIColor clearColor];
        [self.window layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.window.rootViewController = nil;
        self.window = nil;
        [[UIApplication sharedApplication].windows.firstObject makeKeyAndVisible];
        if (completion) {
            completion();
        }
    }];
}

- (void)showInteractive {
    self.window = [[UIWindow alloc] initWithFrame:
                   [[UIScreen mainScreen] bounds]];
    self.intractiveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:self.intractiveGesture];
    self.window.rootViewController = self;
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    [self addViewControllerToWindowConstraints:self];
    
    self.topConstraint.constant = [UIScreen mainScreen].bounds.size.height;
    [self.window layoutIfNeeded];
    self.topConstraint.constant = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.maskType == InteractiveMaskTypeBlack) {
            self.window.backgroundColor = [UIColor blackColor];
        }
        [self.window layoutIfNeeded];
    }];
}

- (void)addViewControllerToWindowConstraints:(UIViewController *)vc {
    vc.view.translatesAutoresizingMaskIntoConstraints = false;
    
    self.topConstraint = [vc.view.topAnchor constraintEqualToAnchor:self.window.topAnchor];
    NSLayoutConstraint *heightAnchor = [vc.view.heightAnchor
                                        constraintEqualToConstant:self.window.bounds.size.height];
    NSLayoutConstraint *leftAnchor = [vc.view.leadingAnchor
                                      constraintEqualToAnchor:self.window.leadingAnchor];
    NSLayoutConstraint *rightAnchor = [vc.view.trailingAnchor
                                       constraintEqualToAnchor:self.window.trailingAnchor];
    
    [self.window addConstraints:@[self.topConstraint, heightAnchor, leftAnchor, rightAnchor]];
}

- (void)didPan:(CGFloat)y {
    self.topConstraint.constant = y;
    if (self.maskType == InteractiveMaskTypeBlack && self.window != nil) {
        CGFloat alpha = fabs(self.view.bounds.size.height/2 - self.view.center.y) /
        (self.view.bounds.size.height/2);
        self.window.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1 - alpha)];
    }
}

- (void)resetWindow {
    self.topConstraint.constant = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.maskType == InteractiveMaskTypeBlack) {
            self.window.backgroundColor = [UIColor blackColor];
        }
        [self.window layoutIfNeeded];
    }];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    
    if (self.allowedDismissDirection == DismissDirectionNone)
        return;
    
    if (sender == self.intractiveGesture) {
        CGFloat yMovement = [sender translationInView:self.view].y;
        
        if (!self.directionLock) {
            [self didPan:yMovement];
        }
        else if (self.allowedDismissDirection == DismissDirectionTop && yMovement < 0 ){
            [self didPan:yMovement];
        }
        else if (self.allowedDismissDirection == DismissDirectionBottom && yMovement > 0) {
            [self didPan:yMovement];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint velocity = [sender velocityInView:self.view];
            
            if (velocity.y < -100 && self.allowedDismissDirection != DismissDirectionBottom) {
                [self dismissWindowDirection:DismissDirectionTop completion:nil];
            }
            else if (velocity.y > 100  && self.allowedDismissDirection != DismissDirectionTop) {
                [self dismissWindowDirection:DismissDirectionBottom completion:nil];
            } else {
                [self resetWindow];
            }
        }
    }
}

@end

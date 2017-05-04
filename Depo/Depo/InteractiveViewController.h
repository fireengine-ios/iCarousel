//
//  InteractiveViewController.h
//  SwipeToDismiss
//
//  Created by Ömer Burak Kır on 2/24/17.
//  Copyright © 2017 Ömer Burak Kır. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, DismissDirection) {
    DismissDirectionBottom,
    DismissDirectionTop,
    DismissDirectionBoth,
    DismissDirectionNone,
};

typedef NS_ENUM(NSUInteger, InteractiveMaskType) {
    InteractiveMaskTypeBlack,
    InteractiveMaskTypeClear,
};

@interface InteractiveViewController : UIViewController

@property (nonatomic, assign) DismissDirection allowedDismissDirection;
@property (nonatomic, assign) BOOL directionLock;
@property (nonatomic, assign) InteractiveMaskType maskType;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *intractiveGesture;

- (void)showInteractive;
@end

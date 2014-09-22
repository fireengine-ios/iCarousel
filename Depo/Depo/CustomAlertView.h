//
//  CustomAlertView.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2014 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@class CustomAlertView;

@protocol CustomAlertDelegate <NSObject>
- (void) didDismissCustomAlert:(CustomAlertView *) alertView;
@end

@interface CustomAlertView : UIView

@property (nonatomic, strong) id<CustomAlertDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withMessage:(NSString *) message withModalType:(ModalType) modalType;

@end

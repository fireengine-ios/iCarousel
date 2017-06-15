//
//  CustomConfirmView.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2014 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@class CustomConfirmView;

@protocol CustomConfirmDelegate <NSObject>
- (void) didRejectCustomAlert:(CustomConfirmView *) alertView;
- (void) didApproveCustomAlert:(CustomConfirmView *) alertView;
@end

@interface CustomConfirmView : UIView

@property (nonatomic, strong) id<CustomConfirmDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withCancelTitle:(NSString *) cancelTitle withApproveTitle:(NSString *) approveTitle withMessage:(NSString *) message withModalType:(ModalType) modalType;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withCancelTitle:(NSString *) cancelTitle withApproveTitle:(NSString *) approveTitle withMessage:(NSString *) message withModalType:(ModalType) modalType shouldShowCheck:(BOOL) checkFlag withCheckKey:(NSString *) checkKey;

@end

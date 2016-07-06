//
//  CustomEntryPopupView.h
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralTextField.h"

@protocol CustomEntryPopupDelegate <NSObject>
- (void) customEntryDidDismissWithValue:(NSString *) val;
@end

@interface CustomEntryPopupView : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<CustomEntryPopupDelegate> delegate;
@property (nonatomic, strong) GeneralTextField *field;
@property (nonatomic, strong) UIView *modalView;

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withButtonTitle:(NSString *) buttonTitleVal;

@end

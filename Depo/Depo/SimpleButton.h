//
//  SimpleButton.h
//  Depo
//
//  Created by Mahir on 10/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleButton : UIButton

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withTitleColor:(UIColor *) titleColor withTitleFont:(UIFont *) titleFont withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor withCornerRadius:(float) cornerRadius;

@end

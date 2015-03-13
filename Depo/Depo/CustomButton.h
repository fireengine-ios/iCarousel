//
//  CustomButton.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton {
    UILabel *titleLabel;
}

- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName;
- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font;
- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font fillXY:(BOOL) shouldFillXY;
- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font withColor:(UIColor *) textColor;
- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withSideTitle:(NSString *) title withFont:(UIFont *) font withColor:(UIColor *) textColor;
- (void) changeTextColor:(UIColor *) newColor;
- (void) updateImage:(NSString *) newImgName;

@end

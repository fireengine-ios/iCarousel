//
//  CheckButton.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckButton : UIButton {
    UIImageView *bgImgView;
}

@property (nonatomic) BOOL isChecked;
@property (nonatomic, strong) UIImage *checkedImage;
@property (nonatomic, strong) UIImage *uncheckedImage;

- (id)initWithFrame:(CGRect)frame isInitiallyChecked:(BOOL) isInitiallyChecked;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title isInitiallyChecked:(BOOL) isInitiallyChecked;

@end

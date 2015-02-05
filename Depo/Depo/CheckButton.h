//
//  CheckButton.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckButtonDelegate <NSObject>
- (void) checkButtonWasChecked;
- (void) checkButtonWasUnchecked;
@end

@interface CheckButton : UIButton {
    UIImageView *bgImgView;
}

@property (nonatomic) BOOL isChecked;
@property (nonatomic, strong) id<CheckButtonDelegate> checkDelegate;
@property (nonatomic, strong) UIImage *checkedImage;
@property (nonatomic, strong) UIImage *uncheckedImage;

- (id)initWithFrame:(CGRect)frame isInitiallyChecked:(BOOL) isInitiallyChecked;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title isInitiallyChecked:(BOOL) isInitiallyChecked;
- (void) toggle;
- (void) manuallyCheck;
- (void) manuallyUncheck;

@end

//
//  ToggleButton.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleButton : UIButton

@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) UIImage *activeImg;
@property (nonatomic, strong) UIImage *deactiveImg;
@property (nonatomic, strong) UIImageView *bgImgView;

- (id)initWithFrame:(CGRect)frame withActiveImageName:(NSString *) activeImgName withDeactiveImageName:(NSString *) deactiveImgName isInitiallyActive:(BOOL) isInitiallyActive;
- (void) unselect;

@end

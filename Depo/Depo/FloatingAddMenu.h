//
//  FloatingAddMenu.h
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTypeButton.h"

@interface FloatingAddMenu : UIView {
    int buttonHeight;
}

@property (nonatomic, strong) AddTypeButton *folderButton;
@property (nonatomic, strong) AddTypeButton *musicButton;
@property (nonatomic, strong) AddTypeButton *photoButton;
@property (nonatomic, strong) AddTypeButton *cameraButton;
@property (nonatomic) CGPoint initialPoint;

- (id)initWithFrame:(CGRect)frame withBasePoint:(CGPoint) basePoint;
- (void) presentWithAnimation;
- (void) dismissWithAnimation;

@end

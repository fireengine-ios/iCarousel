//
//  ToggleButton.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "ToggleButton.h"

@implementation ToggleButton

@synthesize isActive;
@synthesize activeImg;
@synthesize deactiveImg;
@synthesize bgImgView;

- (id)initWithFrame:(CGRect)frame withActiveImageName:(NSString *) activeImgName withDeactiveImageName:(NSString *) deactiveImgName isInitiallyActive:(BOOL) isInitiallyActive {
    self = [super initWithFrame:frame];
    if (self) {
        self.activeImg = [UIImage imageNamed:activeImgName];
        self.deactiveImg = [UIImage imageNamed:deactiveImgName];
        self.isActive = isInitiallyActive;
        
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        if(isActive) {
            bgImgView.image = activeImg;
        } else {
            bgImgView.image = deactiveImg;
        }
        [self addSubview:bgImgView];
        
        [self addTarget:self action:@selector(toggleBg) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void) toggleBg {
    if(!isActive) {
        isActive = YES;
        bgImgView.image = activeImg;
    }
}

- (void) unselect {
    isActive = NO;
    bgImgView.image = deactiveImg;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

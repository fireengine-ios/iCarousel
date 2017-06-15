//
//  VolumeLevelIndicator.m
//  Depo
//
//  Created by Mahir on 10/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "VolumeLevelIndicator.h"

@implementation VolumeLevelIndicator

@synthesize delegate;
@synthesize bgView;
@synthesize activeImg;
@synthesize passiveImg;
@synthesize isActive;
@synthesize level;

- (id)initWithFrame:(CGRect)frame withLevel:(int) _level {
    self = [super initWithFrame:frame];
    if (self) {
        self.level = _level;
        
        self.activeImg = [UIImage imageNamed:@"volume_current_level.png"];
        self.passiveImg = [UIImage imageNamed:@"volume_level.png"];
        
        bgView = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImageName:@"volume_level.png"];
        [bgView addTarget:self action:@selector(volClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgView];
    }
    return self;
}

- (void) volClicked {
    [delegate volumeLevelIndicatorWasSelected:self.level];
}

- (void) manuallyActivate {
    self.isActive = YES;
    [bgView updateImage:@"volume_current_level.png"];
}

- (void) manuallyDeactivate {
    self.isActive = NO;
    [bgView updateImage:@"volume_level.png"];
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

//
//  FloatingAddMenu.m
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FloatingAddMenu.h"

@implementation FloatingAddMenu

@synthesize folderButton;
@synthesize musicButton;
@synthesize photoButton;
@synthesize cameraButton;
@synthesize initialPoint;

- (id)initWithFrame:(CGRect)frame withBasePoint:(CGPoint) basePoint {
    self = [super initWithFrame:frame];
    if (self) {
        self.initialPoint = basePoint;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"action_bar_bg.png"]];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;
        [self addSubview:bgView];
        
        buttonHeight = (self.frame.size.height - 120) / 4;
        
        folderButton = [[AddTypeButton alloc] initWithFrame:CGRectMake(0, 0, 100, buttonHeight) withAddType:AddTypeFolder];
        folderButton.center = initialPoint;
        [self addSubview:folderButton];

        musicButton = [[AddTypeButton alloc] initWithFrame:CGRectMake(0, 0, 100, buttonHeight) withAddType:AddTypeMusic];
        musicButton.center = initialPoint;
        [self addSubview:musicButton];

        photoButton = [[AddTypeButton alloc] initWithFrame:CGRectMake(0, 0, 100, buttonHeight) withAddType:AddTypePhoto];
        photoButton.center = initialPoint;
        [self addSubview:photoButton];

        cameraButton = [[AddTypeButton alloc] initWithFrame:CGRectMake(0, 0, 100, buttonHeight) withAddType:AddTypeCamera];
        cameraButton.center = initialPoint;
        [self addSubview:cameraButton];
    }
    return self;
}

- (void) presentWithAnimation {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:0
                     animations:^{
                         folderButton.frame = CGRectMake(110, 20, 100, buttonHeight);
                         folderButton.alpha = 1.0f;
                         musicButton.frame = CGRectMake(110, buttonHeight + 20, 100, buttonHeight);
                         musicButton.alpha = 1.0f;
                         photoButton.frame = CGRectMake(110, buttonHeight*2 + 20, 100, buttonHeight);
                         photoButton.alpha = 1.0f;
                         cameraButton.frame = CGRectMake(110, buttonHeight*3 + 20, 100, buttonHeight);
                         cameraButton.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void) dismissWithAnimation {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:0
                     animations:^{
                         folderButton.center = initialPoint;
                         musicButton.center = initialPoint;
                         photoButton.center = initialPoint;
                         cameraButton.center = initialPoint;

                         folderButton.alpha = 0.0f;
                         musicButton.alpha = 0.0f;
                         photoButton.alpha = 0.0f;
                         cameraButton.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                     }];
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

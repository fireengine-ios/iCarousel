//
//  FloatingAddMenu.m
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FloatingAddMenu.h"
#import "AppUtil.h"

@implementation FloatingAddMenu

@synthesize delegate;
@synthesize buttons;
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
        
        buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) loadButtons:(NSArray *) buttonTypes {
    for(AddTypeButton *button in buttons) {
        [button removeFromSuperview];
    }
    [buttons removeAllObjects];
    
    for(NSString *buttonType in buttonTypes) {
        AddType addType = [AppUtil strToAddType:buttonType];
        AddTypeButton *button = [[AddTypeButton alloc] initWithFrame:CGRectMake(0, 0, 130, 90) withAddType:addType];
        button.center = initialPoint;
        button.tag = addType;
        [button addTarget:self action:@selector(triggerAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttons addObject:button];
    }
}

- (void) presentWithAnimation {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:0
                     animations:^{
                         int counter = 1;
                         for(AddTypeButton *button in buttons) {
                             button.frame = CGRectMake(95, initialPoint.y - 35 - counter * 90, 130, 90);
                             button.alpha = 1.0f;
                             counter ++;
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void) dismissWithAnimation {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:0
                     animations:^{
                         for(AddTypeButton *button in buttons) {
                             button.center = initialPoint;
                             button.alpha = 0.0f;
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void) triggerAddButton:(id)sender {
    AddTypeButton *senderButton = (AddTypeButton *) sender;
    switch (senderButton.tag) {
        case AddTypeFolder:
            [delegate floatingMenuDidTriggerAddFolder];
            break;
        case AddTypeMusic:
            [delegate floatingMenuDidTriggerAddMusic];
            break;
        case AddTypePhoto:
            [delegate floatingMenuDidTriggerAddPhoto];
            break;
        case AddTypeCamera:
            [delegate floatingMenuDidTriggerCamera];
            break;
        case AddTypeAlbum:
            [delegate floatingMenuDidTriggerAddAlbum];
            break;
        default:
            break;
    }
}

- (void) triggerAddFolder {
    [delegate floatingMenuDidTriggerAddFolder];
}

- (void) triggerAddMusic {
    [delegate floatingMenuDidTriggerAddMusic];
}

- (void) triggerAddPhoto {
    [delegate floatingMenuDidTriggerAddPhoto];
}

- (void) triggerCamera {
    [delegate floatingMenuDidTriggerCamera];
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

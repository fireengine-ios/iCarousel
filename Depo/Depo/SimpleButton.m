//
//  SimpleButton.m
//  Depo
//
//  Created by Mahir on 10/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SimpleButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "CustomLabel.h"

@implementation SimpleButton

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 1.0f;
        self.backgroundColor = bgColor;

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    return self;
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

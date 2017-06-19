//
//  AddTypeButton.m
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AddTypeButton.h"
#import "AppUtil.h"
#import "CustomLabel.h"

@implementation AddTypeButton

@synthesize addType;

- (id)initWithFrame:(CGRect)frame withAddType:(AddType) type {
    self = [super initWithFrame:frame];
    if (self) {
        self.addType = type;
        
        UIImage *bgImg = [UIImage imageNamed:[AppUtil buttonImgNameByAddType:self.addType]];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 60)/2, (self.frame.size.height - 80)/2, 60, 60)];
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, bgImgView.frame.origin.y + 65, self.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor] withText:[AppUtil buttonTitleByAddType:self.addType]];
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

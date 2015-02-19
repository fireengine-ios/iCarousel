//
//  UsageButton.m
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UsageButton.h"
#import "AppUtil.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation UsageButton

- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withStorage:(long long) storage {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByUsageType:type]];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - iconImg.size.width)/2, (self.frame.size.height - iconImg.size.height)/2 - 20, iconImg.size.width, iconImg.size.height)];
        bgImgView.image = iconImg;
        [self addSubview:bgImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:[Util transformedHugeSizeValue:storage] withAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

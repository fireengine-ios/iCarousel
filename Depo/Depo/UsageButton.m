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

@synthesize countLabel;

- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withStorage:(long long) storage withFileCount:(int) fileCount {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByUsageType:type]];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - iconImg.size.width)/2, (self.frame.size.height - iconImg.size.height)/2 - 20, iconImg.size.width, iconImg.size.height)];
        bgImgView.image = iconImg;
        [self addSubview:bgImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 32, self.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:[Util transformedHugeSizeValue:storage] withAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];

        countLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 16, self.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:[NSString stringWithFormat:@"(%d adet)", fileCount] withAlignment:NSTextAlignmentCenter];
        [self addSubview:countLabel];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withCountValue:(NSString *) countVal {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByUsageType:type]];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - iconImg.size.width)/2, (self.frame.size.height - iconImg.size.height)/2 - 20, iconImg.size.width, iconImg.size.height)];
        bgImgView.image = iconImg;
        [self addSubview:bgImgView];
        
        countLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 32, self.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:countVal withAlignment:NSTextAlignmentCenter];
        [self addSubview:countLabel];
    }
    return self;
}

- (void) updateCountValue:(NSString *) newVal {
    countLabel.text = newVal;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

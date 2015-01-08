//
//  HomeUsageView.m
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "HomeUsageView.h"
#import "CustomLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation HomeUsageView

- (id) initWithFrame:(CGRect)frame withUsage:(Usage *) usage {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self.layer setCornerRadius:65];
        
        CustomLabel *totalUsageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:36] withColor:[Util UIColorForHexColor:@"363e4f"] withText:[Util transformedSizeValue:[usage usedStorage]] withAlignment:NSTextAlignmentCenter];
        [self addSubview:totalUsageLabel];
        
        NSString *totalStorageVal = [NSString stringWithFormat:NSLocalizedString(@"HomeUsageTotalStorage", @""), [Util transformedSizeValue:usage.totalStorage]];
        
        CustomLabel *totalStorageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 75, self.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"7b8497"] withText:totalStorageVal withAlignment:NSTextAlignmentCenter];
        [self addSubview:totalStorageLabel];
        
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

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
#import "AppConstants.h"

@implementation HomeUsageView

- (id) initWithFrame:(CGRect)frame withUsage:(Usage *) usage {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self.layer setCornerRadius:self.frame.size.width/2];
        
        CustomLabel *totalUsageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:36] withColor:[Util UIColorForHexColor:@"363e4f"] withText:[usage usedStorage] == 0 ? @"--" : [Util transformedHugeSizeValue:[usage usedStorage]] withAlignment:NSTextAlignmentCenter];
        totalUsageLabel.isAccessibilityElement = YES;
        totalUsageLabel.accessibilityIdentifier = @"totalUsageLabelHome";
        [self addSubview:totalUsageLabel];
        
        NSString *totalStorageVal = [NSString stringWithFormat:NSLocalizedString(@"HomeUsageTotalStorage", @""), [Util transformedHugeSizeValueDecimalIfNecessary:usage.totalStorage]];
        
        CustomLabel *totalStorageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 75, self.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"7b8497"] withText:totalStorageVal withAlignment:NSTextAlignmentCenter];
        totalStorageLabel.isAccessibilityElement = YES;
        totalStorageLabel.accessibilityIdentifier = @"totalStorageLabelHome";
        [self addSubview:totalStorageLabel];
        
        if(IS_IPAD) {
            totalUsageLabel.frame = CGRectMake(0, 100, self.frame.size.width, 80);
            CGPoint totalUsageLabelCenter = totalUsageLabel.center;
            totalUsageLabelCenter.y = frame.size.height / 2;
            totalUsageLabel.center = totalUsageLabelCenter;
            
            totalUsageLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:72];
            
            totalStorageLabel.frame = CGRectMake(0, 200, self.frame.size.width, 40);
            CGPoint totalStorageLabelCenter = totalStorageLabel.center;
            totalStorageLabelCenter.y = frame.size.height / 2 + 60;
            totalStorageLabel.center = totalStorageLabelCenter;
            
            totalStorageLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:32];
        }

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

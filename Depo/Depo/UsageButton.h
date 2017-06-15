//
//  UsageButton.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "CustomLabel.h"

@interface UsageButton : UIButton

@property (nonatomic, strong) CustomLabel *countLabel;

- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withStorage:(long long) storage withFileCount:(int) fileCount;
- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withCountValue:(NSString *) countVal;
- (void) updateCountValue:(NSString *) newVal;

@end

//
//  UsageButton.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface UsageButton : UIButton

- (id) initWithFrame:(CGRect)frame withUsage:(UsageType) type withStorage:(float) storage;

@end

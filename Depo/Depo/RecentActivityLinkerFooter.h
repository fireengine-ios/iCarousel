//
//  RecentActivityLinkerFooter.h
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecentActivityLinkerDelegate <NSObject>
- (void) recentActivityLinkerDidTriggerPage;
@end

@interface RecentActivityLinkerFooter : UIView

@property (nonatomic, strong) id<RecentActivityLinkerDelegate> delegate;

@end

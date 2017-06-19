//
//  RecentActivityLinkerFooter.m
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentActivityLinkerFooter.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppConstants.h"

@implementation RecentActivityLinkerFooter

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        UIImage *iconImg = [UIImage imageNamed:@"recent_activity_icon.png"];
        UIImage *indicator = [UIImage imageNamed:@"white_right_arrow_icon.png"];
        
        float leftIndex = 20;
        float lineHeight = 20;
        float iconSize = iconImg.size.width;
        CGSize indicatorSize = CGSizeMake(indicator.size.width, indicator.size.height);
        
        UIFont *titleFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:17];
        
        if(IS_IPAD) {
            leftIndex = 30;
            lineHeight = 28;
            iconSize = iconImg.size.width*3/2;
            indicatorSize = CGSizeMake(indicator.size.width*3/2, indicator.size.height*3/2);
            titleFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:25];
        }
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(leftIndex, (self.frame.size.height - iconSize)/2, iconSize, iconSize)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(leftIndex*2 + iconSize, (self.frame.size.height - lineHeight)/2, self.frame.size.width - (leftIndex*2 + iconSize), lineHeight) withFont:titleFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"RecentActivityLinkerTitle", @"")];
        [self addSubview:titleLabel];
        
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - indicatorSize.width, (self.frame.size.height - indicatorSize.height)/2, indicatorSize.width, indicatorSize.height)];
        indicatorView.image = indicator;
        [self addSubview:indicatorView];
    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate recentActivityLinkerDidTriggerPage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

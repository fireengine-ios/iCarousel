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

@implementation RecentActivityLinkerFooter

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        UIImage *iconImg = [UIImage imageNamed:@"recent_activity_icon.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, (self.frame.size.height - 20)/2, self.frame.size.width - 100, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"RecentActivityLinkerTitle", @"")];
        [self addSubview:titleLabel];
        
        UIImage *indicator = [UIImage imageNamed:@"white_right_arrow_icon.png"];
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 30, (self.frame.size.height - indicator.size.height)/2, indicator.size.width, indicator.size.height)];
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

//
//  RecentActivityHeaderView.m
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentActivityHeaderView.h"
#import "Util.h"
#import "CustomLabel.h"
#import "NSDate+Utilities.h"

@implementation RecentActivityHeaderView

- (id) initWithFrame:(CGRect)frame withDate:(NSDate *) _date withIndex:(int) indexOfSection {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(45, (self.frame.size.height - 16)/2, self.frame.size.width - 55, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:11] withColor:[Util UIColorForHexColor:@"3fb0e8"] withText:@""];
        [self addSubview:titleLabel];
        
        UIView *timeline = [[UIView alloc] initWithFrame:CGRectMake(25, 0, 2, self.frame.size.height)];
        if(indexOfSection == 0) {
            timeline.frame = CGRectMake(25, self.frame.size.height/2, 2, self.frame.size.height/2);
        }
        timeline.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        [self addSubview:timeline];
        
        UIImage *dayImg = [UIImage imageNamed:@"day_bullet.png"];
        UIImageView *dayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(26 - dayImg.size.width/2, (self.frame.size.height - dayImg.size.height)/2, dayImg.size.width, dayImg.size.height)];
        dayImgView.image = dayImg;
        [self addSubview:dayImgView];

        if([_date isToday]) {
            titleLabel.text = NSLocalizedString(@"TodayTitle", @"");
        } else if([_date isYesterday]) {
            titleLabel.text = NSLocalizedString(@"YesterdayTitle", @"");
        } else {
            NSDateFormatter *shortDateFormat = [[NSDateFormatter alloc] init];
            [shortDateFormat setDateFormat:NSLocalizedString(@"RecentSectionDateFormat", @"")];
            titleLabel.text = [shortDateFormat stringFromDate:_date];
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

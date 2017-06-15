//
//  RecentActivityCell.m
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentActivityCell.h"
#import "Util.h"
#import "AppUtil.h"
#import "UIImageView+WebCache.h"

@implementation RecentActivityCell

@synthesize activity;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withActivity:(Activity *) _activity {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.activity = _activity;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        timeline = [[UIView alloc] initWithFrame:CGRectMake(25, 0, 2, self.frame.size.height)];
        timeline.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        [self addSubview:timeline];
        
        UIImage *bullet = [UIImage imageNamed:@"activity_bullet.png"];
        UIImageView *bulletView = [[UIImageView alloc] initWithFrame:CGRectMake(26 - bullet.size.width/2, 18, bullet.size.width, bullet.size.height)];
        bulletView.image = bullet;
        [self addSubview:bulletView];
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByActivityType:self.activity.activityType]];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 0, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(95, 5, self.frame.size.width - 110, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"7f828b"] withText:self.activity.title];
        if (self.activity.activityType == ActivityTypeWelcome)
            titleLabel.text = NSLocalizedString(@"Welcome", @"");
        [self addSubview:titleLabel];
        
        dateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(95, self.frame.size.height-40, self.frame.size.width - 110, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:12] withColor:[Util UIColorForHexColor:@"7f828b"] withText:self.activity.visibleHour];
        [self addSubview:dateLabel];
        
        if([self.activity.rawFileType isEqualToString:@"IMAGE"]) {
            int counter = 0;
            for(MetaFile *file in self.activity.actionItemList) {
                if(counter < 3) {
                    UIImageView *fileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(95 + counter * 35, 30, 30, 30)];
                    [fileImgView sd_setImageWithURL:[NSURL URLWithString:file.detail.thumbSmallUrl]];
                    [self addSubview:fileImgView];
                }
                counter ++;
            }
        } else {
            int counter = 0;
            for(MetaFile *file in self.activity.actionItemList) {
                CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(95, 30 + counter*18, self.frame.size.width - 110, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"3fb0e8"] withText:file.visibleName];
                [self addSubview:nameLabel];
                counter ++;
            }
        }
        
        if (self.activity.activityType != ActivityTypeWelcome) {
            separator = [[UIView alloc] initWithFrame:CGRectMake(95, self.frame.size.height-10, self.frame.size.width-95, 1)];
            separator.backgroundColor = [Util UIColorForHexColor:@"e9ebef"];
            [self addSubview:separator];
        }

    }
    return self;
}

- (void) layoutSubviews {
    timeline.frame = CGRectMake(25, 0, 2, self.frame.size.height);
    separator.frame = CGRectMake(95, self.frame.size.height-10, self.frame.size.width-95, 1);
    dateLabel.frame = CGRectMake(95, self.frame.size.height-30, self.frame.size.width - 110, 15);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

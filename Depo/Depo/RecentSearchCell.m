//
//  RecentSearchCell.m
//  Depo
//
//  Created by NCO on 24/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentSearchCell.h"
#import "Util.h"

@implementation RecentSearchCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHistory:(SearchHistory *)history {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int left = 20;
        
        if (history.type.length > 0) {
            UIImage *iconImg = [UIImage imageNamed:@"ic_av_timer"];
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 7, iconImg.size.width, iconImg.size.height)];
            imageView.image = iconImg;
            [self addSubview:imageView];
            left += 30;
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 11, 280, 20)];
        [titleLabel setText:history.searchText];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        titleLabel.textColor = [Util UIColorForHexColor:@"292F3E"];
        titleLabel.backgroundColor= [UIColor clearColor];
        [self addSubview:titleLabel];
        
        UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
        [self addSubview:greyLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

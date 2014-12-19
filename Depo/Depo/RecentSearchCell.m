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

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 280, 20)];
        [titleLabel setText:title];
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

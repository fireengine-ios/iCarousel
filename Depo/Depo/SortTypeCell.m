//
//  SortTypeCell.m
//  Depo
//
//  Created by Mahir on 30/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SortTypeCell.h"
#import "CustomLabel.h"
#import "AppUtil.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface SortTypeCell () {
    UIView *progressSeparator;
    UIImageView *tickView;
}
@end

@implementation SortTypeCell

@synthesize type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSortType:(SortType) _type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = _type;

        self.backgroundColor = [UIColor whiteColor];
        
        CGRect nameFieldRect = CGRectMake(20, 14, self.frame.size.width - 40, 22);
        
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"363E4F"] withText:[AppUtil sortTypeTitleByEnum:self.type]];
        [self addSubview:nameLabel];
        
        if(APPDELEGATE.session.sortType == self.type) {
            UIImage *tickImg = [UIImage imageNamed:@"nav_blue_tick.png"];
            tickView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 34, 20, 14, 11)];
            tickView.image = tickImg;
            [self addSubview:tickView];
        }
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"E1E1E1"];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
    }
    return self;
}

- (void) layoutSubviews {
    progressSeparator.frame = CGRectMake(0, 49, self.frame.size.width, 1);
    if(tickView) {
        tickView.frame = CGRectMake(self.frame.size.width - (IS_IPAD ? 100 : 34), 20, 14, 11);
    }
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  FeedbackChoiceCell.m
//  Depo
//
//  Created by Mahir Tarlan on 18/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FeedbackChoiceCell.h"
#import "CustomLabel.h"
#import "Util.h"

@interface FeedbackChoiceCell() {
    UIImageView *iconView;
    CustomLabel *titleLabel;
    UIImageView *indicatorView;
}
@end

@implementation FeedbackChoiceCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(FeedBackType) choiceType {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *iconImg = [UIImage imageNamed:choiceType == FeedBackTypeSuggestion ? @"icon_suggestion":@"icon_complaint.png"];
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(50, (self.frame.size.height - 20)/2, self.frame.size.width - 100, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:choiceType == FeedBackTypeSuggestion ? NSLocalizedString(@"FeedbackTypeSuggestion", @"") : NSLocalizedString(@"FeedbackTypeComplaint", @"")];
        [self addSubview:titleLabel];

        UIImage *indicatorImg = [UIImage imageNamed:@"icon_select_off.png"];
        indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - indicatorImg.size.width - 20, (self.frame.size.height - indicatorImg.size.height)/2, indicatorImg.size.width, indicatorImg.size.height)];
        indicatorView.image = indicatorImg;
        [self addSubview:indicatorView];
    }
    return self;
}

- (void) layoutSubviews {
    iconView.frame = CGRectMake(20, (self.frame.size.height - iconView.frame.size.height)/2, iconView.frame.size.width, iconView.frame.size.height);
    titleLabel.frame = CGRectMake(50, (self.frame.size.height - 20)/2, self.frame.size.width - 100, 20);
    indicatorView.frame = CGRectMake(self.frame.size.width - indicatorView.frame.size.width - 20, (self.frame.size.height - indicatorView.frame.size.height)/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        indicatorView.image = [UIImage imageNamed:@"icon_select_on.png"];
    } else {
        indicatorView.image = [UIImage imageNamed:@"icon_select_off.png"];
    }
}

@end

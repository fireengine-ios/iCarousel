//
//  SettingsCategoryCell.m
//  Depo
//
//  Created by Mustafa Talha Celik on 22.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "TitleCell.h"
#import "ToggleButton.h"

@implementation TitleCell

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText titleColor:(UIColor *)_titleColor subTitleText:(NSString *)_subTitleText iconName:(NSString *)_iconName hasSeparator:(BOOL)_hasSeparator isLink:(BOOL)_isLink linkText:(NSString *)_linkText cellHeight:(double)_cellHeight {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellHeight = _cellHeight;
        titleText = _titleText;
        titleColor = _titleColor == nil ? [Util UIColorForHexColor:@"292F3E"] : _titleColor;
        titleFontSize = cellHeight > 60 ? 19 : 18;
        iconName = _iconName;
        hasIcon = [iconName isEqualToString:@""] ? NO : YES;
        titleLeft = hasIcon ? 65 : 20;
        subTitleText = _subTitleText;
        hasSubTitle = [subTitleText isEqualToString:@""] ? NO : YES;
        titleTop = [subTitleText isEqualToString:@""] ? cellHeight/2-10 : cellHeight/2-18;
        isLink = _isLink;
        linkText = _linkText;
        hasSeparator = _hasSeparator;
        
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self drawTitle];
        if (hasSubTitle)
            [self drawSubTitle];
        if (hasIcon)
            [self drawIcon];
        if (isLink)
            [self drawLinkArea];
        if (hasSeparator)
            [self drawSeparator];
    }
    return self;
}

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier iconName:(NSString *)_iconName titleText:(NSString *)_titleText checkStatus:(BOOL)_checkStatus {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        hasCheckStatus = YES;
        checkStatus = _checkStatus;
        cellHeight = 44;
        titleText = _titleText;
        titleColor = [Util UIColorForHexColor:@"292F3E"];
        titleLeft = 20;
        titleTop = 14;
        titleFontSize = 18;
        
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self drawTitle];
        [self drawTickArea];
        [self drawSeparator];
    }
    return self;
}
- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText subTitletext:(NSString *)_subTitleText toggleStatus:(BOOL)_toggleStatus {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        hasToggle = YES;
        toggleStatus = _toggleStatus;
        cellHeight = [subTitleText isEqualToString:@""] ? 54 : 69;
        titleText = _titleText;
        titleColor = [Util UIColorForHexColor:@"292F3E"];
        titleLeft = 20;
        titleTop = 14;
        titleFontSize = 18;
        
        subTitleText = _subTitleText;
        hasSubTitle = [subTitleText isEqualToString:@""] ? NO : YES;
        
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self drawTitle];
        if (hasSubTitle)
            [self drawSubTitle];
        [self drawToggleArea];
        [self drawSeparator];
    }
    return self;
}

- (void)drawTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, titleTop, 280, 20)];
    [titleLabel setText:titleText];
    titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:titleFontSize];
    titleLabel.textColor = titleColor;
    [self addSubview:titleLabel];
}

- (void)drawSubTitle {
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, titleTop + 20, 280, 20)];
    [subTitleLabel setText:subTitleText];
    subTitleLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
    subTitleLabel.textColor = [Util UIColorForHexColor:@"5D667C"];
    [self addSubview:subTitleLabel];
}

- (void)drawIcon {
    UIImageView *categoryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, cellHeight/2-15, 29, 29)];
    categoryIcon.image = [UIImage imageNamed:iconName];
    [self addSubview:categoryIcon];
}

- (void)drawLinkArea {
    UIImageView *rightIcon = [[UIImageView alloc]initWithFrame:CGRectMake(293, cellHeight/2-7, 7, 13)];
    rightIcon.image = [UIImage imageNamed:@"right_grey_icon"];
    [self addSubview:rightIcon];
    
    if(![linkText isEqualToString:@""]) {
        UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight/2-10, 268, 20)];
        [linkLabel setText:linkText];
        linkLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:17];
        linkLabel.textColor = [Util UIColorForHexColor:@"5D667C"];
        linkLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:linkLabel];
    }
}

- (void)drawTickArea {
    if(checkStatus) {
        UIImageView *tickIcon = [[UIImageView alloc]initWithFrame:CGRectMake(287, cellHeight/2-5.5, 14, 11)];
        tickIcon.image = [UIImage imageNamed:@"tick_icon"];
        [self addSubview:tickIcon];
    }
}

- (void)drawToggleArea {
    ToggleButton *toggleButton = [[ToggleButton alloc]initWithFrame:CGRectMake(249, cellHeight/2-16.5, 53, 32) withActiveImageName:@"toggle_on@2x" withDeactiveImageName:@"toggle_off@2x" isInitiallyActive:toggleStatus];
    [self addSubview:toggleButton];
}

- (void)drawSeparator {
    UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [self addSubview:greyLine];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

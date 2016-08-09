//
//  TitleCell.m
//  Depo
//
//  Created by Salih on 22.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "TitleCell.h"
#import "ToggleButton.h"

@interface TitleCell () {
    UILabel *titleLabel;
    UILabel *subTitleLabel;
    UIImageView *categoryIcon;
    UIImageView *rightIcon;
    UILabel *linkLabel;
    UIView *greyLine;
}
@end

@implementation TitleCell

@synthesize switchButton;

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText titleColor:(UIColor *)_titleColor subTitleText:(NSString *)_subTitleText iconName:(NSString *)_iconName hasSeparator:(BOOL)_hasSeparator isLink:(BOOL)_isLink linkText:(NSString *)_linkText cellHeight:(double)_cellHeight {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellHeight = _cellHeight;
        titleText = _titleText;
        titleColor = _titleColor == nil ? [Util UIColorForHexColor:@"292F3E"] : _titleColor;
        titleFontSize = cellHeight > 60 ? 19 : 17;
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
        titleFontSize = 17;
        
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self drawTitle];
        [self drawTickArea];
        [self drawSeparator];
    }
    return self;
}

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText subTitletext:(NSString *)_subTitleText SwitchButtonStatus:(BOOL)_switchButtonStatus {
    self = [self initWithCellStyle:style reuseIdentifier:reuseIdentifier titleText:_titleText subTitletext:_subTitleText SwitchButtonStatus:_switchButtonStatus hasSeparator:YES];
    return self;
}

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText subTitletext:(NSString *)_subTitleText SwitchButtonStatus:(BOOL)_switchButtonStatus hasSeparator:(BOOL)_hasSeparator {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        switchButtonStatus = _switchButtonStatus;
        subTitleText = _subTitleText;
        titleText = _titleText;
        
        cellHeight = [subTitleText isEqualToString:@""] ? 54 : 69;
        titleColor = [Util UIColorForHexColor:@"292F3E"];
        titleLeft = 20;
        titleTop = [subTitleText isEqualToString:@""] ? 17 : 14;
        titleFontSize = 17;
        hasSeparator = _hasSeparator;
        hasSubTitle = [subTitleText isEqualToString:@""] ? NO : YES;
        
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self drawTitle];
        if (hasSubTitle)
            [self drawSubTitle];
        [self drawSwitchArea];
        if (hasSeparator)
            [self drawSeparator];
    }
    return self;
}

- (void)drawTitle {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, titleTop, 280, 20)];
    [titleLabel setText:titleText];
    titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:titleFontSize];
    titleLabel.textColor = titleColor;
    titleLabel.backgroundColor= [UIColor clearColor];
    [self addSubview:titleLabel];
}

- (void)drawSubTitle {
    subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, titleTop + 20, 280, 20)];
    [subTitleLabel setText:subTitleText];
    subTitleLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
    subTitleLabel.textColor = [Util UIColorForHexColor:@"5D667C"];
    subTitleLabel.backgroundColor= [UIColor clearColor];
    [self addSubview:subTitleLabel];
}

- (void)drawIcon {
    categoryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, cellHeight/2-15, 29, 29)];
    categoryIcon.contentMode = UIViewContentModeScaleAspectFit;
    categoryIcon.image = [UIImage imageNamed:iconName];
    [self addSubview:categoryIcon];
}

- (void)drawLinkArea {
    rightIcon = [[UIImageView alloc]initWithFrame:CGRectMake(293, cellHeight/2-7, 7, 13)];
    rightIcon.image = [UIImage imageNamed:@"right_grey_icon"];
    [self addSubview:rightIcon];
    
    if(![linkText isEqualToString:@""]) {
        linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight/2-10, 268, 20)];
        [linkLabel setText:linkText];
        linkLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:17];
        linkLabel.textColor = [Util UIColorForHexColor:@"5D667C"];
        linkLabel.textAlignment = NSTextAlignmentRight;
        linkLabel.backgroundColor= [UIColor clearColor];
        [self addSubview:linkLabel];
    }
}

- (void)drawTickArea {
    tickIcon = [[UIImageView alloc]initWithFrame:CGRectMake(287, cellHeight/2-5.5, 14, 11)];
    tickIcon.image = [UIImage imageNamed:@"tick_icon"];
    tickIcon.hidden = !checkStatus;
    [self addSubview:tickIcon];
}

- (void)drawSwitchArea {
    self.switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.switchButton setOn:switchButtonStatus animated:NO];
    self.accessoryView = self.switchButton;
}

- (void)drawSeparator {
    greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [self addSubview:greyLine];
}

- (void)showTick {
    tickIcon.hidden = NO;
}

- (void)hideTick {
    tickIcon.hidden = YES;
}

- (void) layoutSubviews {
    titleTop = (subTitleText == nil || [subTitleText isEqualToString:@""]) ? (self.frame.size.height - 20)/2 : self.frame.size.height/2 - 20;
    
    if(titleLabel) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, self.frame.size.width - titleLeft, 20);
    }
    if(subTitleLabel) {
        subTitleLabel.frame = CGRectMake(titleLeft, titleTop + 20, self.frame.size.width - titleLeft, 20);
    }
    if(categoryIcon) {
        categoryIcon.frame = CGRectMake(15, (self.frame.size.height-29)/2, 29, 29);
    }
    if(rightIcon) {
        rightIcon.frame = CGRectMake(self.frame.size.width - 27, (self.frame.size.height-13)/2, 7, 13);
    }
    if(linkLabel) {
        linkLabel.frame = CGRectMake(15, (self.frame.size.height-20)/2, 268, 20);
    }
    if(greyLine) {
        greyLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    }
    if(tickIcon) {
        tickIcon.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 11)/2, 14, 11);
    }
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

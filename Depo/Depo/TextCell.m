//
//  TextCell.m
//  Depo
//
//  Created by Mustafa Talha Celik on 25.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "TextCell.h"
#import "Util.h"

@implementation TextCell

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText titleColor:(UIColor *)_titleColor contentText:(NSString *)_contentText contentTextColor:(UIColor *)_contentTextColor backgroundColor:(UIColor *)_backgroundColor hasSeparator:(BOOL)_hasSeparator
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleText = _titleText;
        hasTitle = [titleText isEqualToString:@""] ? NO : YES;
        titleColor = _titleColor == nil ? [Util UIColorForHexColor:@"292F3E"] : _titleColor;
        contentText = _contentText;
        contentTextColor = _contentTextColor == nil ? [Util UIColorForHexColor:@"5D667C"] : _contentTextColor;
        contentTextTop = hasTitle ? 30 : 25;
        contentTextHeight = [Util calculateHeightForText:contentText forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
        cellHeight = contentTextHeight + 43;
        cellHeight += hasTitle ? 5 : 0;
        backgroundColor = _backgroundColor == nil ?  [UIColor clearColor] : _backgroundColor;
        hasSeparator = _hasSeparator;
        
        self.backgroundColor = backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(hasTitle)
            [self drawTitle];
        [self drawContentText];
        if(hasSeparator)
           [self drawSeparator];
        
    }
    return self;
}

- (void)drawTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 300, 20)];
    [titleLabel setText:titleText];
    titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:12];
    titleLabel.textColor = titleColor;
    [self addSubview:titleLabel];
}

- (void)drawContentText {
    UILabel *contentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, contentTextTop, 280, contentTextHeight)];
    [contentTextLabel setText:contentText];
    contentTextLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:14];
    contentTextLabel.textColor = contentTextColor;
    contentTextLabel.numberOfLines = 0;
    [self addSubview:contentTextLabel];
}

- (void)drawSeparator {
    UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [self addSubview:greyLine];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

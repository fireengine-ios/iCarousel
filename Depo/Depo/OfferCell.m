//
//  OfferCell.m
//  Depo
//
//  Created by Salih Topcu on 13.02.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "OfferCell.h"
#import "Util.h"
//#import "TurkcellSaturaMed.ttf"

@implementation OfferCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText hasSeparator:(BOOL)_hasSeparator topIndex:(CGFloat)_topIndex bottomIndex:(CGFloat)_bottomIndex {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleText = _titleText;
        hasSeparator = _hasSeparator;
        topIndex = _topIndex;
        bottomIndex = _bottomIndex;
        cellHeight = 60 + topIndex + bottomIndex;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self drawTitle];
        if (hasSeparator)
            [self drawSeparator];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText hasSeparator:(BOOL)_hasSeparator {
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier titleText:_titleText hasSeparator:_hasSeparator topIndex:0 bottomIndex:0];
    return self;
}

- (void)drawTitle {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, topIndex + 5, 280, 50)];
    [button setTitle:titleText forState:UIControlStateNormal];
    button.backgroundColor = [Util UIColorForHexColor:@"FEDB13"];
    button.layer.cornerRadius = 5.0f;
    [button setTitleColor:[Util UIColorForHexColor:@"292F3E"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
    button.userInteractionEnabled = NO;
    [self addSubview:button];
}

- (void)drawSeparator {
    UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [self addSubview:greyLine];
}

@end

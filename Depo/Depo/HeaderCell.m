//
//  HeaderCell.m
//  Depo
//
//  Created by Mustafa Talha Celik on 25.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "HeaderCell.h"
#import "Util.h"

@implementation HeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier headerText:(NSString *)_headerText
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headerText = _headerText;
        hasHeader = [headerText isEqualToString:@""] ? NO : YES;
        separatorTop = hasHeader ? 53 : 30;
        
        if (hasHeader)
            [self drawHeader];
        [self drawSeparator];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)drawHeader {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 27, 300, 20)];
    [headerLabel setText:headerText];
    headerLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:12];
    headerLabel.textColor = [Util UIColorForHexColor:@"292F3E"];
    [self addSubview:headerLabel];
}

- (void)drawSeparator {
    UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, separatorTop, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [self addSubview:greyLine];
    
    //    UIView *tempLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    //    tempLine.backgroundColor = [Util UIColorForHexColor:@"FF0000"];
    //    [self addSubview:tempLine];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

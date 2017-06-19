//
//  MessageCell.m
//  Depo
//
//  Created by RDC on 02.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)titleText {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float titleHeight = [Util calculateHeightForText:titleText forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, titleHeight)];
        [titleLabel setText:titleText];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:16];
        titleLabel.textColor = [Util UIColorForHexColor:@"292F3E"];
        titleLabel.numberOfLines = 0;
        titleLabel.backgroundColor= [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:titleLabel];
    }
    return self;
}

@end

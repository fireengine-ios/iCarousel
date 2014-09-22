//
//  MenuSearchCell.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MenuSearchCell.h"

@implementation MenuSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMetaData:(MetaMenu *)_metaData {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.metaData = _metaData;
        
        textField = [[SearchTextField alloc] initWithFrame:CGRectMake(12, 5, 252, 50)];
        [self addSubview:textField];
    }
    return self;
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

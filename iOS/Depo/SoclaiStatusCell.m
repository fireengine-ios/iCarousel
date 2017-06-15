//
//  SoclaiStatusCell.m
//  Depo
//
//  Created by Mahir Tarlan on 09/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SoclaiStatusCell.h"
#import "CustomLabel.h"
#import "Util.h"

@interface SoclaiStatusCell() {
    CustomLabel *titleLabel;
    UIView *separatorView;
}
@end


@implementation SoclaiStatusCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 20)/2, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:titleVal withAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height-1, self.frame.size.width - 40, 1)];
        separatorView.backgroundColor = [Util UIColorForHexColor:@"DDDDDD"];
        //        [self addSubview:separatorView];
    }
    return self;
}

- (void) layoutSubviews {
    titleLabel.frame = CGRectMake(20, (self.frame.size.height - 20)/2, self.frame.size.width - 40, 20);
    separatorView.frame = CGRectMake(20, self.frame.size.height-1, self.frame.size.width - 40, 1);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

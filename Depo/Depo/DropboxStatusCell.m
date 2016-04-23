//
//  DropboxStatusCell.m
//  Depo
//
//  Created by Mahir Tarlan on 22/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxStatusCell.h"
#import "CustomLabel.h"
#import "Util.h"

@interface DropboxStatusCell() {
    CustomLabel *titleLabel;
    UIView *separatorView;
}
@end

@implementation DropboxStatusCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 20)/2, self.frame.size.width - 20, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:titleVal];
        [self addSubview:titleLabel];
        
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height-1, self.frame.size.width - 40, 1)];
        separatorView.backgroundColor = [Util UIColorForHexColor:@"DDDDDD"];
        [self addSubview:separatorView];
    }
    return self;
}

- (void) layoutSubviews {
    titleLabel.frame = CGRectMake(20, (self.frame.size.height - 20)/2, self.frame.size.width - 20, 20);
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

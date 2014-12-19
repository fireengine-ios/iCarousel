//
//  PostLoginPrefCell.m
//  Depo
//
//  Created by Mahir on 11.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginPrefCell.h"
#import "Util.h"
#import "CustomLabel.h"

@implementation PostLoginPrefCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [Util UIColorForHexColor:@"019bd7"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] withColor:[UIColor whiteColor] withText:titleVal];
        [self addSubview:titleLabel];
        
        checkView = [[UIImageView alloc] initWithFrame:CGRectMake(296, 14, 14, 11)];
        checkView.image = [UIImage imageNamed:@"check_icon.png"];
        checkView.hidden = YES;
        [self addSubview:checkView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        checkView.hidden = NO;
    } else {
        checkView.hidden = YES;
    }
}

@end

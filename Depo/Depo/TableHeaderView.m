//
//  TableHeaderView.m
//  Depo
//
//  Created by NCO on 01/12/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "TableHeaderView.h"
#import "Util.h"

@implementation TableHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andTitleText:(NSString *)ttlTxt {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[Util UIColorForHexColor:@"F1F2F6"]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, 280, 11)];
        [titleLabel setText:ttlTxt];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaMed" size:12];
        titleLabel.textColor = [Util UIColorForHexColor:@"292F3E"];
        [self addSubview:titleLabel];
    }
    
    return self;
}

@end

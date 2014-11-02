//
//  MoveModalFooterView.m
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoveModalFooterView.h"
#import "Util.h"
#import "CustomButton.h"

@implementation MoveModalFooterView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        CustomButton *moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 9, 20, 18, 20) withImageName:@"white_move_icon.png"];
        [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moveButton];
    }
    return self;
}

- (void) moveClicked {
    [delegate moveModalFooterDidSelectMove];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

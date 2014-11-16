//
//  FooterActionsMenuView.m
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FooterActionsMenuView.h"
#import "Util.h"

@implementation FooterActionsMenuView

@synthesize delegate;
@synthesize shareButton;
@synthesize moveButton;
@synthesize deleteButton;

- (id) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES];
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        if(shareFlag) {
            shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(15, 19, 16, 22) withImageName:@"white_share_icon.png"];
            [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:shareButton];
        }
        
        if(moveFlag) {
            moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 9, 20, 18, 20) withImageName:@"white_move_icon.png"];
            [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moveButton];
        }
        
        if(deleteFlag) {
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 35, 19, 20, 21) withImageName:@"white_delete_icon.png"];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteButton];
        }
    }
    return self;
}

- (void) shareClicked {
    [delegate footerActionMenuDidSelectShare:self];
}

- (void) moveClicked {
    [delegate footerActionMenuDidSelectMove:self];
}

- (void) deleteClicked {
    [delegate footerActionMenuDidSelectDelete:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

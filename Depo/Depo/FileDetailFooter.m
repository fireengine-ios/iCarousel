//
//  FileDetailFooter.m
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileDetailFooter.h"
#import "Util.h"
#import "MPush.h"

@implementation FileDetailFooter

@synthesize delegate;
@synthesize shareButton;
@synthesize deleteButton;
@synthesize separatorView;
@synthesize printButton;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withPrintEnabled:YES];
}

- (id)initWithFrame:(CGRect)frame withPrintEnabled:(BOOL) printEnabledFlag {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"191e24"];
        
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        separatorView.backgroundColor = [Util UIColorForHexColor:@"05070b"];
        [self addSubview:separatorView];
        
        shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 22)/2, 16, 22) withImageName:@"white_share_icon.png"];
        [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];

        deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21) withImageName:@"white_delete_icon.png"];
        [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        
        if(printEnabledFlag) {
            printButton = [[CustomButton alloc] initWithFrame:CGRectMake(60, (self.frame.size.height - 22)/2, 22, 23) withImageName:@"white_print_icon.png"];
            [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:printButton];
        }

    }
    return self;
}

- (void) updateInnerViews {
    separatorView.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    shareButton.frame = CGRectMake(20, (self.frame.size.height - 22)/2, 16, 22);
    deleteButton.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21);
}

- (void) shareClicked {
    [MPush hitTag:@"share_button_clicked"];
    [MPush hitEvent:@"share_button_clicked"];
    
    [delegate fileDetailFooterDidTriggerShare];
}

- (void) deleteClicked {
    [MPush hitTag:@"delete_button_clicked"];
    [MPush hitEvent:@"delete_button_clicked"];

    [delegate fileDetailFooterDidTriggerDelete];
}

- (void) printClicked {
    [MPush hitTag:@"cellograph_button_clicked"];
    [MPush hitEvent:@"cellograph_button_clicked"];

    [delegate fileDetailFooterDidTriggerPrint];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

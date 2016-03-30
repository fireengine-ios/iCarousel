//
//  FooterActionsMenuView.m
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FooterActionsMenuView.h"
#import "Util.h"
#import "MPush.h"

@implementation FooterActionsMenuView

@synthesize delegate;
@synthesize shareButton;
@synthesize moveButton;
@synthesize deleteButton;
@synthesize printButton;

- (id) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:NO];
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        if(shareFlag) {
            shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(15, 19, 106, 22) withImageName:@"white_share_icon.png" withSideTitle:NSLocalizedString(@"ShareTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
            [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:shareButton];
        }
        
        if(moveFlag) {
            moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(100, 20, 80, 20) withImageName:@"white_move_icon.png" withSideTitle:NSLocalizedString(@"MoveTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
            [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moveButton];
        }
        
        if(deleteFlag) {
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 35, 19, 20, 21) withImageName:@"white_delete_icon.png"];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteButton];
        }
        if (printFlag) {
            printButton = [[CustomButton alloc] initWithFrame:CGRectMake(185, 20, 80, 20) withImageName:@"white_print_icon.png" withSideTitle:NSLocalizedString(@"PrintTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
            [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:printButton];
        }

    }
    return self;
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag isMoveAlbum:(BOOL) moveRename {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        if(shareFlag) {
            shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(15, 19, 80, 22) withImageName:@"white_share_icon.png" withSideTitle:NSLocalizedString(@"ShareTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
            [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:shareButton];
        }
        
        if(moveFlag) {
            CGFloat width = [Util calculateWidthForText:NSLocalizedString(@"MoveToAlbum", @"") forHeight:20 forFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15]];
            moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(shareButton.frame.size.width+5,20 , width+30,20 ) withImageName:@"white_move_icon.png" withSideTitle:NSLocalizedString(@"AddToAlbumTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
            [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moveButton];
        }
        
        if(deleteFlag) {
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 35, 19, 20, 21) withImageName:@"white_delete_icon.png"];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteButton];
        }
        if (printFlag) {
            printButton = [[CustomButton alloc] initWithFrame:CGRectMake(moveButton.frame.origin.x+moveButton.frame.size.width+5, 20, 80, 20) withImageName:@"white_print_icon.png" withSideTitle:NSLocalizedString(@"PrintTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
            [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:printButton];
        }
        
    }
    return self;
}


- (void) shareClicked {
    [MPush hitTag:@"share_button_clicked"];
    [MPush hitEvent:@"share_button_clicked"];

    [delegate footerActionMenuDidSelectShare:self];
}

- (void) moveClicked {
    [delegate footerActionMenuDidSelectMove:self];
}

- (void) deleteClicked {
    [MPush hitTag:@"delete_button_clicked"];
    [MPush hitEvent:@"delete_button_clicked"];

    [delegate footerActionMenuDidSelectDelete:self];
}

- (void) printClicked {
    [MPush hitTag:@"cellograph_button_clicked"];
    [MPush hitEvent:@"cellograph_button_clicked"];

    [delegate footerActionMenuDidSelectPrint:self];
}

- (void) hidePrintIcon {
    if (self.printButton) {
        self.printButton.hidden = YES;
    }
}

- (void) showPrintIcon {
    if (self.printButton) {
        self.printButton.hidden = NO;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

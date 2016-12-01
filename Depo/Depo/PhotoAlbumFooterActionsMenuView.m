//
//  PhotoAlbumFooterActionsMenuView.m
//  Depo
//
//  Created by Seyma Tanoglu on 30/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "PhotoAlbumFooterActionsMenuView.h"
#import "Util.h"
#import "MPush.h"

@implementation PhotoAlbumFooterActionsMenuView

@synthesize delegate;
@synthesize shareButton;
@synthesize moveButton;
@synthesize removeButton;
@synthesize downloadButton;
@synthesize printButton;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(15, 9, 50, 22) withImageName:@"white_share_icon.png" withTitleBelow:NSLocalizedString(@"ShareTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
        [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
        
        moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(shareButton.frame.origin.x+shareButton.frame.size.width+5, shareButton.frame.origin.y + 2 , 50, 20) withImageName:@"white_move_icon.png" withTitleBelow:NSLocalizedString(@"MoveTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
        [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moveButton];
        
        downloadButton = [[CustomButton alloc] initWithFrame:CGRectMake(moveButton.frame.origin.x+moveButton.frame.size.width+7, shareButton.frame.origin.y - 1, 60, 20) withImageName:@"icon_bottom_indir.png" withTitleBelow:NSLocalizedString(@"DownloadTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
        [downloadButton addTarget:self action:@selector(downloadClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:downloadButton];
        
        printButton = [[CustomButton alloc] initWithFrame:CGRectMake(downloadButton.frame.origin.x+downloadButton.frame.size.width+7, moveButton.frame.origin.y + 1, 60, 20) withImageName:@"white_print_icon.png" withTitleBelow:NSLocalizedString(@"PrintTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
        [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:printButton];
        
         removeButton = [[CustomButton alloc] initWithFrame:CGRectMake(printButton.frame.origin.x+printButton.frame.size.width+5, downloadButton.frame.origin.y, 50, 20)  withImageName:@"icon_bottom_kaldir.png" withTitleBelow:NSLocalizedString(@"RemoveTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
        [removeButton addTarget:self action:@selector(removeClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:removeButton];
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

- (void) removeClicked {
    [MPush hitTag:@"remove_button_clicked"];
    [MPush hitEvent:@"remove_button_clicked"];
    
    [delegate footerActionMenuDidSelectRemove:self];
}

- (void) downloadClicked {
    [MPush hitTag:@"download_button_clicked"];
    [MPush hitEvent:@"download_button_clicked"];
    
    [delegate footerActionMenuDidSelectDownload:self];
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

@end



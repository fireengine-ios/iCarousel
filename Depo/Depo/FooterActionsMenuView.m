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

@interface FooterActionsMenuView() {
    BOOL isExpanded;
    CGRect originalFrame;
}
@end

@implementation FooterActionsMenuView

@synthesize delegate;
@synthesize shareButton;
@synthesize moveButton;
@synthesize downloadButton;
@synthesize deleteButton;
@synthesize printButton;
@synthesize removeButton;
@synthesize syncButton;
@synthesize moreButton;

- (id) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:NO];
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag {
    return [self initWithFrame:frame shouldShowShare:shareFlag shouldShowMove:moveFlag shouldShowDelete:deleteFlag shouldShowDownload:NO shouldShowPrint:printFlag];
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag  shouldShowDownload:(BOOL)downloadFlag shouldShowPrint:(BOOL)printFlag  {
    return [self initWithFrame:frame shouldShowShare:shareFlag shouldShowMove:moveFlag shouldShowDelete:deleteFlag shouldShowRemove: NO shouldShowDownload:downloadFlag shouldShowPrint:printFlag];
}

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowRemove:(BOOL) removeFlag shouldShowDownload:(BOOL)downloadFlag shouldShowPrint:(BOOL)printFlag {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        int left = 15;
        int top = 9;
        
        NSMutableArray *currentButtons = [@[] mutableCopy];
        
        if(shareFlag) {
            shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, top, 50, 45) withImageName:@"white_share_icon.png" withTitleBelow:NSLocalizedString(@"ShareTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
            [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:shareButton];
            left = shareButton.frame.origin.x+shareButton.frame.size.width+5;
            [currentButtons addObject:shareButton];
        }
        
        if(moveFlag) {
            moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, top + 2 , 50, 43) withImageName:@"white_move_icon.png" withTitleBelow:NSLocalizedString(@"MoveTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor]];
            [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moveButton];
            left = moveButton.frame.origin.x+moveButton.frame.size.width+7;
            
            [currentButtons addObject:moveButton];
        }
        
        if (downloadFlag) {
            downloadButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, shareButton.frame.origin.y - 1, 60, 43) withImageName:@"icon_bottom_indir.png" withTitleBelow:NSLocalizedString(@"DownloadTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[UIColor whiteColor] ];
            [downloadButton addTarget:self action:@selector(downloadClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:downloadButton];
            left = downloadButton.frame.origin.x+downloadButton.frame.size.width+7;
            [currentButtons addObject:downloadButton];
        }
        
        if (printFlag) {
            printButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, top + 3, 60, 43)
                                                withImageName:@"white_print_icon.png"
                                               withTitleBelow:NSLocalizedString(@"PrintTitle", @"")
                                                     withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15]
                                                    withColor:[UIColor whiteColor] ];
            [printButton addTarget:self action:@selector(printClicked)
                  forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:printButton];
            [currentButtons addObject:printButton];
        }
        
        if (removeFlag) {
            removeButton = [[CustomButton alloc] initWithFrame:CGRectMake
                            (printButton.frame.origin.x+printButton.frame.size.width+5, downloadButton.frame.origin.y, 50, 43)
                                                 withImageName:@"icon_bottom_kaldir.png"
                                                withTitleBelow:NSLocalizedString(@"RemoveTitle", @"")
                                                      withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15]
                                                     withColor:[UIColor whiteColor]];
            [removeButton addTarget:self action:@selector(removeClicked)
                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:removeButton];
            [currentButtons addObject:removeButton];
        }

        if(deleteFlag) {
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 35, 5, 20, 44)
                                                 withImageName:@"white_delete_icon.png"];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteButton];
            [currentButtons addObject:deleteButton];
        }
        
        CGFloat widthForButton = self.frame.size.width / currentButtons.count;
        
        for (UIButton *button in currentButtons) {
            NSInteger indexOfButton = [currentButtons indexOfObject:button];
            CGPoint center = button.center;
            center.x = (widthForButton/2) + (widthForButton * indexOfButton);
            button.center = center;
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


// Revisited Grouped Photos Controller footer view new design
-(id)initForPhotosTabWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDownload:(BOOL) downloadFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag isMoveAlbum:(BOOL) moveRename {
    return [self initForPhotosTabWithFrame:frame shouldShowShare:shareFlag shouldShowMove:moveFlag shouldShowDownload:downloadFlag shouldShowDelete:deleteFlag shouldShowPrint:printFlag shouldShowSync:NO isMoveAlbum:moveRename];
}

-(id)initForPhotosTabWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDownload:(BOOL) downloadFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag shouldShowSync:(BOOL) syncFlag isMoveAlbum:(BOOL) moveRename {
    if(self = [super initWithFrame:frame]) {
        originalFrame = frame;
        
        self.backgroundColor = [Util UIColorForHexColor:@"314249"];
        
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaBol" size:15];
        UIColor *whiteColor = [UIColor whiteColor];
        CGFloat height = 40;
        CGFloat xOffset = 10;
        int buttonCount = 0;
        if (shareFlag) buttonCount++;
        if (moveFlag) buttonCount++;
        if (downloadFlag) buttonCount++;
        if (deleteFlag) buttonCount++;
        if (printFlag) buttonCount++;
        if (syncFlag) buttonCount++;
        
        CGFloat buttonWidth = (self.frame.size.width - 20) / buttonCount;
        if(buttonCount > 5) {
            buttonWidth = (self.frame.size.width - 20) / 5;
        }

        BOOL secondRowAvailable = NO;
        int placedButtonCount = 0;
        
        if(shareFlag) {
            shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height) withImageName:@"white_share_icon.png" withTitleBelow:NSLocalizedString(@"ShareTitle", @"") withFont:font withColor:whiteColor];
            [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:shareButton];
            xOffset += buttonWidth;
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 2, self.frame.size.height)];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }
        
        if(moveFlag) {
            moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height)
                                               withImageName:@"white_move_icon.png"
                                              withTitleBelow:NSLocalizedString(@"MoveTitle", @"")
                                                    withFont:font
                                               withColor:whiteColor];
            [moveButton addTarget:self action:@selector(moveClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moveButton];
            xOffset += buttonWidth;
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 2, self.frame.size.height)];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }
        
        if(syncFlag) {
            syncButton = [[CustomButton alloc] initWithFrame:CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height) withImageName:@"icon_bottom_sync_purple.png" withTitleBelow:NSLocalizedString(@"SyncFooterTitle", @"") withFont:font withColor:[Util UIColorForHexColor:@"737884"]];
            syncButton.enabled = NO;
            [syncButton addTarget:self action:@selector(syncClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:syncButton];
            xOffset += buttonWidth;
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 2, self.frame.size.height)];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }

        if(deleteFlag) {
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height) withImageName:@"white_delete_icon.png" withTitleBelow:NSLocalizedString(@"DeleteFooterTitle", @"") withFont:font withColor:whiteColor];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteButton];
            xOffset += buttonWidth + 10;
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 2, self.frame.size.height)];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }
        
        if(printFlag) {
            CGRect buttonRect = CGRectZero;
            CGRect separatorRect = CGRectZero;
            if(buttonCount > 5 && placedButtonCount == 4) {
                secondRowAvailable = YES;
                buttonRect = CGRectMake(10, self.frame.size.height + (self.frame.size.height - height)/2, buttonWidth, height);
                xOffset = buttonWidth + 10;
                separatorRect = CGRectMake(xOffset, self.frame.size.height, 2, self.frame.size.height);
            } else {
                buttonRect = CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height);
                xOffset += buttonWidth + 10;
                separatorRect = CGRectMake(xOffset, 0, 2, self.frame.size.height);
            }
            printButton = [[CustomButton alloc] initWithFrame:buttonRect withImageName:@"white_print_icon.png" withTitleBelow:NSLocalizedString(@"PrintTitle", @"") withFont:font withColor:whiteColor];
            [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:printButton];
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:separatorRect];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }
        if (downloadFlag) {
            CGRect buttonRect = CGRectZero;
            CGRect separatorRect = CGRectZero;
            if(secondRowAvailable) {
                buttonRect = CGRectMake(xOffset, self.frame.size.height + (self.frame.size.height - height)/2, buttonWidth, height);
                xOffset += buttonWidth;
                separatorRect = CGRectMake(xOffset, self.frame.size.height, 2, self.frame.size.height);
            } else if(buttonCount > 5 && placedButtonCount >= 4) {
                secondRowAvailable = YES;
                buttonRect = CGRectMake(10, self.frame.size.height + (self.frame.size.height - height)/2, buttonWidth, height);
                xOffset = buttonWidth + 10;
                separatorRect = CGRectMake(xOffset, self.frame.size.height, 2, self.frame.size.height);
            } else {
                buttonRect = CGRectMake(xOffset, (self.frame.size.height - height)/2, buttonWidth, height);
                xOffset += buttonWidth + 10;
                separatorRect = CGRectMake(xOffset, 0, 2, self.frame.size.height);
            }
            downloadButton = [[CustomButton alloc] initWithFrame:buttonRect withImageName:@"icon_bottom_indir.png" withTitleBelow:NSLocalizedString(@"DownloadTitle", @"") withFont:font withColor:whiteColor];
            [downloadButton addTarget:self action:@selector(downloadClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:downloadButton];
            xOffset += buttonWidth;
            placedButtonCount ++;

            UIView *verticalSeparator = [[UIView alloc] initWithFrame:separatorRect];
            verticalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
            [self addSubview:verticalSeparator];
        }
        
        if(secondRowAvailable) {
            moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - buttonWidth, (self.frame.size.height - height)/2, buttonWidth, height) withImageName:@"white_left_arrow.png"];
            [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
            moreButton.transform = CGAffineTransformMakeRotation(-90 * M_PI/180);
            [self addSubview:moreButton];
        }
        
        UIView *horizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 2)];
        horizontalSeparator.backgroundColor = [Util UIColorForHexColor:@"253341"];
        [self addSubview:horizontalSeparator];
        
    }
    return self;
}

- (void) moreClicked {
    [UIView animateWithDuration:Footer_Animation_Duration animations:^{
        if(isExpanded) {
            self.frame = originalFrame;
            moreButton.transform = CGAffineTransformMakeRotation(-90 * M_PI/180);
        } else {
            self.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y - originalFrame.size.height, originalFrame.size.width, originalFrame.size.height*2);
            moreButton.transform = CGAffineTransformIdentity;
        }
    }];
    
    isExpanded = !isExpanded;
    [delegate footerActionMenuDidSelectMore:self];
}

- (void) syncClicked {
    [MPush hitTag:@"sync_button_clicked"];
    [MPush hitEvent:@"sync_button_clicked"];
    
    [delegate footerActionMenuDidSelectSync:self];
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

- (void) disableSyncButton {
    if(syncButton && syncButton.isEnabled) {
        syncButton.enabled = NO;
        [syncButton updateTopImage:@"icon_bottom_sync_purple.png"];
        [syncButton changeTextColor:[Util UIColorForHexColor:@"737884"]];
    }
}

- (void) enableSyncButton {
    if(syncButton && !syncButton.isEnabled) {
        syncButton.enabled = YES;
        [syncButton updateTopImage:@"icon_bottom_sync.png"];
        [syncButton changeTextColor:[UIColor whiteColor]];
    }
}

- (void) disableDeleteButton {
    if(deleteButton && deleteButton.isEnabled) {
        deleteButton.enabled = NO;
        [deleteButton updateTopImage:@"icon_bottom_delete_purple.png"];
        [deleteButton changeTextColor:[Util UIColorForHexColor:@"737884"]];
    }
}

- (void) enableDeleteButton {
    if(deleteButton && !deleteButton.isEnabled) {
        deleteButton.enabled = YES;
        [deleteButton updateTopImage:@"white_delete_icon.png"];
        [deleteButton changeTextColor:[UIColor whiteColor]];
    }
}

- (void) disableMoveButton {
    if(moveButton && moveButton.isEnabled) {
        moveButton.enabled = NO;
        moveButton.alpha = 0.4f;
    }
}

- (void) enableMoveButton {
    if(moveButton && !moveButton.isEnabled) {
        moveButton.enabled = YES;
        moveButton.alpha = 1.0f;
    }
}

- (void) disablePrintButton {
    if(printButton && printButton.isEnabled) {
        printButton.enabled = NO;
        printButton.alpha = 0.4f;
    }
}

- (void) enablePrintButton {
    if(printButton && !printButton.isEnabled) {
        printButton.enabled = YES;
        printButton.alpha = 1.0f;
    }
}

- (void) disableDownloadButton {
    if(downloadButton && downloadButton.isEnabled) {
        downloadButton.enabled = NO;
        downloadButton.alpha = 0.4f;
    }
}

- (void) enableDownloadButton {
    if(downloadButton && !downloadButton.isEnabled) {
        downloadButton.enabled = YES;
        downloadButton.alpha = 1.0f;
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

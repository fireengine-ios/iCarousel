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
@synthesize downloadButton;
@synthesize removeButton;
@synthesize separatorView;
@synthesize printButton;

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame withPrintEnabled:YES withAlbum:nil];
}

- (id)initWithFrame:(CGRect)frame withAlbum:(PhotoAlbum*)album{
    return [self initWithFrame:frame withPrintEnabled:YES withAlbum:album];
}

- (id)initWithFrame:(CGRect)frame withPrintEnabled:(BOOL) printEnabledFlag withAlbum:(PhotoAlbum*)album{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"191e24"];
        
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        separatorView.backgroundColor = [Util UIColorForHexColor:@"05070b"];
        [self addSubview:separatorView];
        
        shareButton = [[CustomButton alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 22)/2, 16, 22) withImageName:@"white_share_icon.png"];
        [shareButton addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
        shareButton.isAccessibilityElement = YES;
        shareButton.accessibilityIdentifier = @"shareButtonFileFooter";
        [self addSubview:shareButton];

        if (album) {
            removeButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21) withImageName:@"icon_bottom_kaldir.png"];
            [removeButton addTarget:self action:@selector(removeFromAlbumClicked) forControlEvents:UIControlEventTouchUpInside];
            removeButton.isAccessibilityElement = YES;
            removeButton.accessibilityIdentifier = @"removeButtonFileFooter";
            [self addSubview:removeButton];
        }
        else{
            deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21) withImageName:@"white_delete_icon.png"];
            [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.isAccessibilityElement = YES;
            deleteButton.accessibilityIdentifier = @"deleteButtonFileFooter";
            [self addSubview:deleteButton];
        }
        
        if(printEnabledFlag) {
            printButton = [[CustomButton alloc] initWithFrame:CGRectMake(60, (self.frame.size.height - 22)/2, 22, 23) withImageName:@"white_print_icon.png"];
            [printButton addTarget:self action:@selector(printClicked) forControlEvents:UIControlEventTouchUpInside];
            printButton.isAccessibilityElement = YES;
            printButton.accessibilityIdentifier = @"printButtonFileFooter";
            [self addSubview:printButton];
        }
        
        downloadButton = [[CustomButton alloc] initWithFrame:CGRectMake(100, (self.frame.size.height - 22)/2, 26, 24) withImageName:@"icon_bottom_indir.png"];
        [downloadButton addTarget:self action:@selector(downloadClicked) forControlEvents:UIControlEventTouchUpInside];
        downloadButton.isAccessibilityElement = YES;
        downloadButton.accessibilityIdentifier = @"downloadButtonFileFooter";
        [self addSubview:downloadButton];

    }
    return self;
}

- (void) updateInnerViews {
    separatorView.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    shareButton.frame = CGRectMake(20, (self.frame.size.height - 22)/2, 16, 22);
    deleteButton.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21);
    removeButton.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 21)/2, 20, 21);
}

- (void) shareClicked {
    [MPush hitTag:@"share_button_clicked"];
    [MPush hitEvent:@"share_button_clicked"];
    
    [delegate fileDetailFooterDidTriggerShare];
}

- (void) downloadClicked {
    [MPush hitTag:@"download_button_clicked"];
    [MPush hitEvent:@"download_button_clicked"];
    
    [delegate fileDetailFooterDidTriggerDownload];
}

- (void) deleteClicked {
    [MPush hitTag:@"delete_button_clicked"];
    [MPush hitEvent:@"delete_button_clicked"];

    [delegate fileDetailFooterDidTriggerDelete];
}

- (void) removeFromAlbumClicked {
    [MPush hitTag:@"removeFromAlbum_button_clicked"];
    [MPush hitEvent:@"removeFromAlbum_button_clicked"];
    
    [delegate fileDetailFooterDidTriggerRemoveFromAlbum];
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

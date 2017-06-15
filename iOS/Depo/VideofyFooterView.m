//
//  VideofyFooterView.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyFooterView.h"
#import "Util.h"
#import "CustomButton.h"

@implementation VideofyFooterView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];

        CustomButton *deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 21)/2, 20, 21) withImageName:@"white_delete_icon.png"];
        [deleteButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];

        CustomButton *musicButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, (self.frame.size.height - 30)/2, 30, 30) withImageName:@"icon_bottom_addmusic.png"];
        [musicButton addTarget:self action:@selector(musicClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:musicButton];

        
    }
    return self;
}

- (void) deleteClicked {
    [delegate videofyFooterDeleteClicked];
}

- (void) musicClicked {
    [delegate videofyFooterMusicClicked];
}

@end

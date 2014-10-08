//
//  PhotoHeaderSegmentView.m
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoHeaderSegmentView.h"
#import "Util.h"

@implementation PhotoHeaderSegmentView

@synthesize delegate;
@synthesize photoButton;
@synthesize albumButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"363E4F"];

        photoButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 24)/2, 160, 24) withImageName:nil withTitle:NSLocalizedString(@"PhotoHeaderPhotosButton", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [photoButton addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoButton];

        albumButton = [[CustomButton alloc] initWithFrame:CGRectMake(160, (self.frame.size.height - 24)/2, 160, 24) withImageName:nil withTitle:NSLocalizedString(@"PhotoHeaderAlbumsButton", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"3FB0E8"]];
        [albumButton addTarget:self action:@selector(albumClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:albumButton];
        
        UIImage *flapImg = [UIImage imageNamed:@"menu_select_white_flap.png"];
        flapView = [[UIImageView alloc] initWithFrame:CGRectMake((160 - flapImg.size.width)/2, self.frame.size.height - flapImg.size.height, flapImg.size.width, flapImg.size.height)];
        flapView.image = flapImg;
        [self addSubview:flapView];
    }
    return self;
}

- (void) photoClicked {
    [photoButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
    [albumButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
    flapView.frame = CGRectMake((160 - flapView.frame.size.width)/2, self.frame.size.height - flapView.frame.size.height, flapView.frame.size.width, flapView.frame.size.height);
    
    [delegate photoHeaderDidSelectPhotosSegment];
}

- (void) albumClicked {
    [photoButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
    [albumButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
    flapView.frame = CGRectMake(160 + (160 - flapView.frame.size.width)/2, self.frame.size.height - flapView.frame.size.height, flapView.frame.size.width, flapView.frame.size.height);

    [delegate photoHeaderDidSelectAlbumsSegment];
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

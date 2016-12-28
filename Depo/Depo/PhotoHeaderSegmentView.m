//
//  PhotoHeaderSegmentView.m
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoHeaderSegmentView.h"
#import "Util.h"
#import "AppConstants.h"

@implementation PhotoHeaderSegmentView

@synthesize delegate;
@synthesize photoButton;
@synthesize albumButton;
@synthesize firstBgImg;
@synthesize secondBgImg;
@synthesize deactivated;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.firstBgImg = [UIImage imageNamed:@"photo_header_with_flap_first.png"];
        self.secondBgImg = [UIImage imageNamed:@"photo_header_with_flap_second.png"];
        
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.image = firstBgImg;
        [self addSubview:bgView];

        CGRect photoButtonRect = CGRectMake(10, (self.frame.size.height - 24)/2, 150, 24);
        CGRect albumButtonRect = CGRectMake(160, (self.frame.size.height - 24)/2, 150, 24);
        
        if(IS_IPAD) {
            photoButtonRect = CGRectMake(30, (self.frame.size.height - 24)/2, self.frame.size.width/2-30, 24);
            albumButtonRect = CGRectMake(self.frame.size.width/2, (self.frame.size.height - 24)/2, self.frame.size.width/2-30, 24);
        }
        
        photoButton = [[CustomButton alloc] initWithFrame:photoButtonRect withImageName:nil withTitle:NSLocalizedString(@"PhotoHeaderPhotosButton", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [photoButton addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
        photoButton.isAccessibilityElement = YES;
        photoButton.accessibilityIdentifier = @"photoButtonPhotoHeader";
        [self addSubview:photoButton];
        
        albumButton = [[CustomButton alloc] initWithFrame:albumButtonRect withImageName:nil withTitle:NSLocalizedString(@"PhotoHeaderAlbumsButton", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"3FB0E8"]];
        [albumButton addTarget:self action:@selector(albumClicked) forControlEvents:UIControlEventTouchUpInside];
        albumButton.isAccessibilityElement = YES;
        albumButton.accessibilityIdentifier = @"albumButtonPhotoHeader";
        [self addSubview:albumButton];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-0.25f, 0, 0.5, self.frame.size.height)];
        separator.backgroundColor = [UIColor whiteColor];
        [self addSubview:separator];

    }
    return self;
}

- (void) deactivate {
    self.deactivated = YES;
    photoButton.enabled = NO;
    albumButton.enabled = NO;
}

- (void) reactivate {
    self.deactivated = NO;
    photoButton.enabled = YES;
    albumButton.enabled = YES;
}

- (void) photoClicked {
    [photoButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
    [albumButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
    bgView.image = firstBgImg;
    
    [delegate photoHeaderDidSelectPhotosSegment];
}

- (void) albumClicked {
    [photoButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
    [albumButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
    bgView.image = secondBgImg;

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

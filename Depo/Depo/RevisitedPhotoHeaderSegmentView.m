//
//  RevisitedPhotoHeaderSegmentView.m
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedPhotoHeaderSegmentView.h"
#import "Util.h"

@interface RevisitedPhotoHeaderSegmentView() {
    float itemWidth;
}
@end

@implementation RevisitedPhotoHeaderSegmentView

@synthesize delegate;
@synthesize indicator;
@synthesize photoButton;
@synthesize albumButton;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        itemWidth = self.frame.size.width / 2;

        UIImage *indicatorImg = [UIImage imageNamed:@"edge_tab.png"];
        
        indicator = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - indicatorImg.size.width)/2, self.frame.size.height - indicatorImg.size.height, indicatorImg.size.width, indicatorImg.size.height)];
        indicator.image = indicatorImg;
        [self addSubview:indicator];
        
        photoButton = [[SimpleButton alloc] initWithFrame:CGRectMake(3, (self.frame.size.height - 20)/2, itemWidth - 6, 20) withTitle:NSLocalizedString(@"PhotoTab", @"") withTitleColor:[UIColor whiteColor] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] isUnderline:NO withUnderlineColor:[UIColor clearColor]];
        [photoButton addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoButton];
        
        UIImageView *firstDividerView = [[UIImageView alloc] initWithFrame:CGRectMake(itemWidth - 1, (self.frame.size.height - 20)/2, 2, 20)];
        firstDividerView.image = [UIImage imageNamed:@"divider_horizontal.png"];
        [self addSubview:firstDividerView];

        albumButton = [[SimpleButton alloc] initWithFrame:CGRectMake(itemWidth + 3, (self.frame.size.height - 20)/2, itemWidth - 6, 20) withTitle:NSLocalizedString(@"AlbumTab", @"") withTitleColor:[UIColor whiteColor] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] isUnderline:NO withUnderlineColor:[UIColor clearColor]];
        albumButton.alpha = 0.6f;
        [albumButton addTarget:self action:@selector(albumClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:albumButton];

    }
    return self;
}

- (void) photoClicked {
    photoButton.alpha = 1.0f;
    albumButton.alpha = 0.6f;
    indicator.frame = CGRectMake((itemWidth - indicator.frame.size.width)/2, self.frame.size.height - indicator.frame.size.height, indicator.frame.size.width, indicator.frame.size.height);
    
    [delegate revisitedPhotoHeaderSegmentPhotoChosen];
}

- (void) albumClicked {
    photoButton.alpha = 0.6f;
    albumButton.alpha = 1.0f;
    indicator.frame = CGRectMake(itemWidth + (itemWidth - indicator.frame.size.width)/2, self.frame.size.height - indicator.frame.size.height, indicator.frame.size.width, indicator.frame.size.height);
    
    [delegate revisitedPhotoHeaderSegmentAlbumChosen];
}

- (void) enableNavigate {
    photoButton.enabled = YES;
    albumButton.enabled = YES;
}

- (void) disableNavigate {
    photoButton.enabled = NO;
    albumButton.enabled = NO;
}

@end

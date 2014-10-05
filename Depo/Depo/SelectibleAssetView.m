//
//  SelectibleAssetView.m
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SelectibleAssetView.h"

@implementation SelectibleAssetView

@synthesize delegate;
@synthesize asset;
@synthesize isSelected;

- (id)initWithFrame:(CGRect)frame withAsset:(ALAsset *) _asset {
    self = [super initWithFrame:frame];
    if (self) {
        self.asset = _asset;

        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imgView.image = [UIImage imageWithCGImage:[asset thumbnail]];
        [self addSubview:imgView];
        
        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        maskView.hidden = YES;
        [self addSubview:maskView];
    }
    return self;
}

- (void) manuallySelect {
    self.isSelected = YES;
    maskView.hidden = NO;
}

- (void) manuallyDeselect {
    self.isSelected = NO;
    maskView.hidden = YES;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isSelected) {
        self.isSelected = NO;
        maskView.hidden = YES;
        [delegate selectibleAssetDidBecomeDeselected:self.asset];
    } else {
        self.isSelected = YES;
        maskView.hidden = NO;
        [delegate selectibleAssetDidBecomeSelected:self.asset];
    }
}

@end

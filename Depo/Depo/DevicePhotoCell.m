//
//  DevicePhotoCell.m
//  Depo
//
//  Created by Mahir Tarlan on 10/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DevicePhotoCell.h"
#import "SyncUtil.h"
#import "ALAssetRepresentation+MD5.h"

@interface DevicePhotoCell() {
    UIImageView *imgView;
    UIImageView *playIconView;
}
@end

@implementation DevicePhotoCell

@synthesize delegate;
@synthesize asset;
@synthesize isSelected;

- (void) loadAsset:(ALAsset *) _asset isSelectedFlag:(BOOL) isSelectedFlag {
    self.asset = _asset;
    self.isSelected = isSelectedFlag;
    
    if(!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
    }
    imgView.image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    
    if(!playIconView) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];
        }
    } else {
        if (![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            [playIconView removeFromSuperview];
            playIconView = nil;
        }
    }
    
    if(!maskView) {
        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        [self addSubview:maskView];
    }

    maskView.hidden = !self.isSelected;
}

- (void) manuallySelect {
    self.isSelected = YES;
    maskView.hidden = NO;
}

- (void) manuallyDeselect {
    self.isSelected = NO;
    maskView.hidden = YES;
}

/*
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isSelected) {
        self.isSelected = NO;
        maskView.hidden = YES;
        [delegate devicePhotoAssetDidBecomeDeselected:self.asset];
    } else {
        self.isSelected = YES;
        maskView.hidden = NO;
        [delegate devicePhotoAssetDidBecomeSelected:self.asset];
    }
}
 */

@end

//
//  VolumeSliderView.h
//  Depo
//
//  Created by Mahir on 13/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "VolumeLevelIndicator.h"

@protocol VolumeSliderDelegate <NSObject>
- (void) volumeSliderDidSelectMute;
- (void) volumeSliderDidSelectMax;
- (void) volumeSliderDidChangeTo:(float) newVolumeVal;
@end

@interface VolumeSliderView : UIView <VolumeLevelDelegate>

@property (nonatomic, strong) id<VolumeSliderDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *volumeLevels;
@property (nonatomic, strong) CustomButton *volumeMuteButton;
@property (nonatomic, strong) CustomButton *volumeFullButton;

- (void) setInitialVolumeLevels:(float) level;
- (void) updateInnerItems;

@end

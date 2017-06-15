//
//  VolumeLevelIndicator.h
//  Depo
//
//  Created by Mahir on 10/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@protocol VolumeLevelDelegate <NSObject>
- (void) volumeLevelIndicatorWasSelected:(int) levelSelected;
@end

@interface VolumeLevelIndicator : UIView

@property (nonatomic, strong) id<VolumeLevelDelegate> delegate;
@property (nonatomic, strong) CustomButton *bgView;
@property (nonatomic, strong) UIImage *activeImg;
@property (nonatomic, strong) UIImage *passiveImg;
@property (nonatomic) BOOL isActive;
@property (nonatomic) int level;

- (id)initWithFrame:(CGRect)frame withLevel:(int) _level;
- (void) manuallyActivate;
- (void) manuallyDeactivate;

@end

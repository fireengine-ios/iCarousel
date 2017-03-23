//
//  RevisitedPhotoHeaderSegmentView.h
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleButton.h"

@protocol RevisitedPhotoHeaderSegmentDelegate <NSObject>
- (void) revisitedPhotoHeaderSegmentPhotoChosen;
- (void) revisitedPhotoHeaderSegmentAlbumChosen;
@end

@interface RevisitedPhotoHeaderSegmentView : UIView

@property (nonatomic, weak) id<RevisitedPhotoHeaderSegmentDelegate> delegate;
@property (nonatomic, strong) UIImageView *indicator;

@property (nonatomic, strong) SimpleButton *photoButton;
@property (nonatomic, strong) SimpleButton *albumButton;

- (void) enableNavigate;
- (void) disableNavigate;

- (void) photoClicked;
- (void) albumClicked;

@end

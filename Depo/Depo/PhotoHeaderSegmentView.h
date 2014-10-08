//
//  PhotoHeaderSegmentView.h
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@protocol PhotoHeaderSegmentDelegate <NSObject>
- (void) photoHeaderDidSelectPhotosSegment;
- (void) photoHeaderDidSelectAlbumsSegment;
@end

@interface PhotoHeaderSegmentView : UIView {
    UIImageView *flapView;
}

@property (nonatomic, strong) id<PhotoHeaderSegmentDelegate> delegate;
@property (nonatomic, strong) CustomButton *photoButton;
@property (nonatomic, strong) CustomButton *albumButton;

@end

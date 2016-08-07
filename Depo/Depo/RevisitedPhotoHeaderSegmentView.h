//
//  RevisitedPhotoHeaderSegmentView.h
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RevisitedPhotoHeaderSegmentDelegate <NSObject>
- (void) revisitedPhotoHeaderSegmentPhotoChosen;
- (void) revisitedPhotoHeaderSegmentCollectionChosen;
- (void) revisitedPhotoHeaderSegmentAlbumChosen;
@end

@interface RevisitedPhotoHeaderSegmentView : UIView

@property (nonatomic, weak) id<RevisitedPhotoHeaderSegmentDelegate> delegate;
@property (nonatomic, strong) UIImageView *indicator;

@end

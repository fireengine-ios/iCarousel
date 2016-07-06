//
//  SquareSequencedPictureView.h
//  Depo
//
//  Created by Mahir Tarlan on 06/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"
#import "MetaFile.h"

@protocol SquareSequencedPictureDelegate <NSObject>
- (void) squareSequencedPictureWasMarkedForFile:(MetaFile *) fileSelected;
- (void) squareSequencedPictureWasUnmarkedForFile:(MetaFile *) fileSelected;
@end

@interface SquareSequencedPictureView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<SquareSequencedPictureDelegate> delegate;
@property (nonatomic, strong) CustomLabel *seqLabel;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic) BOOL isMarked;
@property (nonatomic) int sequence;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSequence:(int) seq;

@end

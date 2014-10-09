//
//  SquareImageView.h
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"

@protocol SquareImageDelegate <NSObject>
- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected;
@end

@interface SquareImageView : UIView

@property (nonatomic, strong) id<SquareImageDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file;

@end

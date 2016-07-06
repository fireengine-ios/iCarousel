//
//  SquareSequencedPictureView.m
//  Depo
//
//  Created by Mahir Tarlan on 06/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SquareSequencedPictureView.h"
#import "UIImageView+AFNetworking.h"

@implementation SquareSequencedPictureView

@synthesize delegate;
@synthesize seqLabel;
@synthesize file;
@synthesize isMarked;
@synthesize sequence;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSequence:(int) seq {
    if(self = [super initWithFrame:frame]) {
        self.sequence = seq;
        self.file = _file;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        [imgView setNoCachedImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"square_placeholder.png"]];
        [self addSubview:imgView];

        UIImageView *maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"overlay_grid_blank.png"];
        [self addSubview:maskView];
        
        seqLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 3, 20, 14) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[UIColor whiteColor] withText:[NSString stringWithFormat:@"%d", seq] withAlignment:NSTextAlignmentCenter];
        [self addSubview:seqLabel];
    }
    return self;
}

@end

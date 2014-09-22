//
//  CustomLabel.m
//  IGMG
//
//  Created by Mahir on 5/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef {
    return [self initWithFrame:frame withFont:fontRef withColor:colorRef withText:textRef withAlignment:NSTextAlignmentLeft];
}

- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef withAlignment:(NSTextAlignment) alignmentRef {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = fontRef;
        self.textColor = colorRef;
        self.text = textRef;
        self.textAlignment = alignmentRef;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef withAlignment:(NSTextAlignment) alignmentRef numberOfLines:(int) lineCount {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = fontRef;
        self.textColor = colorRef;
        self.text = textRef;
        self.textAlignment = alignmentRef;
        self.numberOfLines = lineCount;
    }
    return self;
}

@end

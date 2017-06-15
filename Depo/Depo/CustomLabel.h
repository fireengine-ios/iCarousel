//
//  CustomLabel.h
//  IGMG
//
//  Created by Mahir on 5/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLabel : UILabel

- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef;
- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef withAlignment:(NSTextAlignment) alignmentRef;
- (id)initWithFrame:(CGRect)frame withFont:(UIFont *) fontRef withColor:(UIColor *) colorRef withText:(NSString *) textRef withAlignment:(NSTextAlignment) alignmentRef numberOfLines:(int) lineCount;

@end

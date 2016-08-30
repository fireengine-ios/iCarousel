//
//  MainSearchTextfield.m
//  Depo
//
//  Created by Mahir Tarlan on 30/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MainSearchTextfield.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainSearchTextfield

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        self.layer.borderColor = [Util UIColorForHexColor:@"BEBEBE"].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 6;
        self.placeholder = NSLocalizedString(@"MenuSearch", @"");
        self.textColor = [Util UIColorForHexColor:@"888888"];
        
        self.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:15];
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[Util UIColorForHexColor:@"BEBEBE"] setFill];
//    [[self placeholder] drawInRect:rect withFont:self.font];
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentCenter];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y + 14,
                      bounds.size.width - 40, bounds.size.height - 15);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end

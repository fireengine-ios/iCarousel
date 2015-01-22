//
//  SearchTextField.m
//  Depo
//
//  Created by Mahir on 9/19/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SearchTextField.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@implementation SearchTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
        self.layer.cornerRadius = 6;
        self.placeholder = NSLocalizedString(@"MenuSearch", @"");
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[Util UIColorForHexColor:@"5d6066"] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y + 10,
                      bounds.size.width - 40, bounds.size.height - 20);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end

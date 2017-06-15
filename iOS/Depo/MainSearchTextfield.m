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
        NSString *placeholderVal = NSLocalizedString(@"MenuSearch", @"");
        self.placeholder = placeholderVal;
        self.textColor = [Util UIColorForHexColor:@"5D667C"];
        
        self.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:16];
        
        float placeholderWidth = [Util calculateWidthForText:placeholderVal forHeight:20 forFont:self.font] + 10;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - placeholderWidth)/2 - 24, (self.frame.size.height - 24)/2, 24, 24)];
        iconView.image = [UIImage imageNamed:@"icon_search.png"];
        [self addSubview:iconView];
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[Util UIColorForHexColor:@"5D667C"] setFill];
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

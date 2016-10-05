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

@interface SearchTextField() {
    UIImageView *iconView;
}
@end

@implementation SearchTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
        self.layer.cornerRadius = 6;
        NSString *placeholderVal = NSLocalizedString(@"MenuSearch", @"");
        self.placeholder = placeholderVal;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];

        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (self.frame.size.height - 24)/2, 24, 24)];
        iconView.image = [UIImage imageNamed:@"icon_searchB.png"];
        [self addSubview:iconView];
    }
    return self;
}

- (void) markIcon {
    iconView.image = [UIImage imageNamed:@"icon_search.png"];
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[Util UIColorForHexColor:@"E1E1E1"] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 44, bounds.origin.y + 12,
                      bounds.size.width - 60, bounds.size.height - 18);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end

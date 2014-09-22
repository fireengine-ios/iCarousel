//
//  LoginTextfield.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "LoginTextfield.h"
#import "Util.h"
#import "AppConstants.h"

@implementation LoginTextfield

- (id)initWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText {
    self = [super initWithFrame:frame];
    if (self) {
        self.background = [UIImage imageNamed:@"metin.png"];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentCenter;
        
        UIFont *currentFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        UIColor *color = [Util UIColorForHexColor:@"8C8C8C"];
        self.textColor = color;
        self.font = currentFont;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        if(!IS_BELOW_6) {
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: currentFont}];
        } else {
            self.placeholder = placeholderText;
        }
    }
    return self;
}

- (id)initSecureWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText {
    self = [super initWithFrame:frame];
    if (self) {
        self.background = [UIImage imageNamed:@"metin.png"];
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentCenter;
        self.secureTextEntry = YES;
        
        UIFont *currentFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        UIColor *color = [Util UIColorForHexColor:@"8C8C8C"];
        self.textColor = color;
        self.font = currentFont;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        if(!IS_BELOW_6) {
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: currentFont}];
        } else {
            self.placeholder = placeholderText;
        }
    }
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    if(IS_BELOW_6) {
        CGSize size = [[self placeholder] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        return CGRectMake( (bounds.size.width - size.width)/2 , bounds.origin.y , bounds.size.width , bounds.size.height);
    } else {
        return [super placeholderRectForBounds:bounds];
    }
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    if(IS_BELOW_6) {
        [[Util UIColorForHexColor:@"8C8C8C"] setFill];
        [[self placeholder] drawInRect:rect withFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    } else {
        [super drawPlaceholderInRect:rect];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

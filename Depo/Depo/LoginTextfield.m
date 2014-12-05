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
        self.background = [UIImage imageNamed:@"textfield_bg.png"];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentLeft;
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:15];
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
        self.background = [UIImage imageNamed:@"textfield_bg.png"];
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentLeft;
        self.secureTextEntry = YES;
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:15];
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
    return [super placeholderRectForBounds:CGRectMake(20, bounds.origin.y , bounds.size.width - 40 , bounds.size.height)];
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [super drawPlaceholderInRect:rect];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(20, bounds.origin.y , bounds.size.width - 40 , bounds.size.height)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(20, bounds.origin.y , bounds.size.width - 40 , bounds.size.height)];
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

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

@interface LoginTextfield ()
@property (nonatomic, strong) CALayer *border;
@end

@implementation LoginTextfield

- (id)initWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText {
    self = [super initWithFrame:frame];
    if (self) {
       // self.background = [UIImage imageNamed:@"textfield_bg.png"];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentLeft;
        
//        self.border = [CALayer layer];
//        self.border.contents = (id)[UIImage imageNamed:@"textline_1240.png"].CGImage;
//        CGFloat borderWidth = 2;
//        border.borderColor = [UIColor darkGrayColor].CGColor;
//        self.border.frame = CGRectMake(0, self.frame.size.height - 2 , self.frame.size.width, 2);
        
        //border.borderWidth = borderWidth;
//        [self.layer addSublayer:self.border];
        //self.layer.masksToBounds = YES;
        
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:19];
        UIColor *color = [UIColor colorWithRed:165.0f/255.0f green:165.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
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

- (void)setFrame:(CGRect)frame {
    [self.border removeFromSuperlayer];
    
    self.border = [CALayer layer];
    self.border.contents = (id)[UIImage imageNamed:@"textline_1240.png"].CGImage;
    self.border.frame = CGRectMake(0, frame.size.height - 2 , frame.size.width, 2);
    [self.layer addSublayer:self.border];
    
    [super setFrame:frame];
}

- (id)initSecureWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText {
    self = [super initWithFrame:frame];
    if (self) {
       // self.background = [UIImage imageNamed:@"textfield_bg.png"];
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentLeft;
        self.secureTextEntry = YES;
        
//        CALayer *border = [CALayer layer];
//        border.contents = (id)[UIImage imageNamed:@"textline_1240.png"].CGImage;
//        //        CGFloat borderWidth = 2;
//        //        border.borderColor = [UIColor darkGrayColor].CGColor;
//        border.frame = CGRectMake(0, self.frame.size.height - 2 , self.frame.size.width, 2);
//        
//        //border.borderWidth = borderWidth;
//        [self.layer addSublayer:border];
        //self.layer.masksToBounds = YES;
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:19];
        UIColor *color = [UIColor colorWithRed:165.0f/255.0f green:165.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
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
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor blackColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    return [super placeholderRectForBounds:CGRectMake(0, bounds.origin.y , bounds.size.width - 10 , bounds.size.height - 7)];
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [super drawPlaceholderInRect:rect];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(0, bounds.origin.y + 10 , bounds.size.width - 10 , bounds.size.height - 7)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(0, bounds.origin.y + 10 , bounds.size.width - 10 , bounds.size.height - 7)];
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

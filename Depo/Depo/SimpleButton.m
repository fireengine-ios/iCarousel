//
//  SimpleButton.m
//  Depo
//
//  Created by Mahir on 10/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SimpleButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "CustomLabel.h"
#import <CoreText/CoreText.h>

@implementation SimpleButton

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor {
    return [self initWithFrame:frame withTitle:titleVal withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:borderColor withBgColor:bgColor withCornerRadius:6];
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withTitleColor:(UIColor *) titleColor withTitleFont:(UIFont *) titleFont withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor withCornerRadius:(float) cornerRadius {
    return [self initWithFrame:frame withTitle:titleVal withTitleColor:titleColor withTitleFont:titleFont withBorderColor:borderColor withBgColor:bgColor withCornerRadius:cornerRadius adjustFont:NO];
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withTitleColor:(UIColor *) titleColor withTitleFont:(UIFont *) titleFont withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor withCornerRadius:(float) cornerRadius adjustFont:(BOOL) adjustFontFlag {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = cornerRadius;
        self.clipsToBounds = YES;
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 1.0f;
        self.backgroundColor = bgColor;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20) withFont:titleFont withColor:titleColor withText:titleVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        if(adjustFontFlag) {
            titleLabel.adjustsFontSizeToFitWidth = YES;
        }
        [self addSubview:titleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withTitleColor:(UIColor *) titleColor withTitleFont:(UIFont *) titleFont withBorderColor:(UIColor *) borderColor withBgColor:(UIColor *) bgColor withCornerRadius:(float) cornerRadius withIconName:(NSString *) iconName withIconFrame:(CGRect) iconFrame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = cornerRadius;
        self.clipsToBounds = YES;
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 1.0f;
        self.backgroundColor = bgColor;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20) withFont:titleFont withColor:titleColor withText:titleVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        iconView.image = [UIImage imageNamed:iconName];
        [self addSubview:iconView];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *)titleVal {
    if(self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 15)/2, self.frame.size.width, 15)];
        titleLabel.text = titleVal;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.textColor = [Util UIColorForHexColor:@"787878"];
        [self addSubview:titleLabel];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *)titleVal withAlignment:(NSTextAlignment) alignment isUnderlined:(BOOL) underlineFlag {
    if(self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 15)/2, self.frame.size.width, 15)];
        titleLabel.text = titleVal;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        titleLabel.textAlignment = alignment;
        titleLabel.textColor = [Util UIColorForHexColor:@"787878"];
        [self addSubview:titleLabel];

        if(underlineFlag) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleVal];
            [attString addAttribute:(NSString*) kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:(NSRange){0,[attString length]}];
            titleLabel.attributedText = attString;
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withTitleColor:(UIColor *) titleColor withTitleFont:(UIFont *) titleFont isUnderline:(BOOL) underlineFlag withUnderlineColor:(UIColor *) underlineColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20) withFont:titleFont withColor:titleColor withText:titleVal];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        if(underlineFlag) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleVal];
            [attString addAttribute:(NSString*) kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:(NSRange){0,[attString length]}];
            titleLabel.attributedText = attString;
        }
    }
    return self;
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

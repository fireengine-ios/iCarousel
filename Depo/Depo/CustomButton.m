//
//  CustomButton.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "CustomButton.h"
#import "Util.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - (font.lineHeight  + 5))/2, self.frame.size.width, font.lineHeight  + 5)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = font;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [Util UIColorForHexColor:@"48494C"];
        [self addSubview:titleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font withColor:(UIColor *) textColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - (font.lineHeight  + 5))/2, self.frame.size.width, font.lineHeight  + 5)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = font;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = textColor;
        [self addSubview:titleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageName:(NSString *) imageName withTitle:(NSString *) title withFont:(UIFont *) font fillXY:(BOOL) shouldFillXY {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImgView.image = [UIImage imageNamed:imageName];
        [self addSubview:bgImgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - (font.lineHeight  + 5))/2, self.frame.size.width, font.lineHeight  + 5)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = font;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [Util UIColorForHexColor:@"EEEEEE"];
        [self addSubview:titleLabel];
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

//
//  CheckButton.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "CheckButton.h"
#import "Util.h"

@implementation CheckButton

@synthesize isChecked;
@synthesize checkDelegate;
@synthesize checkedImage;
@synthesize uncheckedImage;

- (id)initWithFrame:(CGRect)frame isInitiallyChecked:(BOOL) isInitiallyChecked {
    self = [super initWithFrame:frame];
    if (self) {
        self.isChecked = isInitiallyChecked;
        self.checkedImage = [UIImage imageNamed:@"dont_show_blue_tick.png"];
        self.uncheckedImage = [UIImage imageNamed:@"check_unchecked_icon.png"];
        
        if(self.isChecked) {
            [self setImage:self.checkedImage forState:UIControlStateNormal];
        } else {
            [self setImage:self.uncheckedImage forState:UIControlStateNormal];
        }
        
//        [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title isInitiallyChecked:(BOOL) isInitiallyChecked {
    self = [super initWithFrame:frame];
    if (self) {
        self.isChecked = isInitiallyChecked;
        self.checkedImage = [UIImage imageNamed:@"dont_show_blue_tick.png"];
        self.uncheckedImage = [UIImage imageNamed:@"check_unchecked_icon.png"];
        
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - checkedImage.size.height)/2, checkedImage.size.width, checkedImage.size.height)];
        [self addSubview:bgImgView];
        
        if(self.isChecked) {
            bgImgView.image = self.checkedImage;
        } else {
            bgImgView.image = self.uncheckedImage;
        }

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgImgView.frame.size.width + 10, (self.frame.size.height - 15)/2, self.frame.size.width - bgImgView.frame.size.width - 10, 15)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [Util UIColorForHexColor:@"787878"];
        [self addSubview:titleLabel];

        [self addTarget:self action:@selector(toggleWithBgView) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) toggle {
    isChecked = !isChecked;
    if(isChecked) {
        [checkDelegate checkButtonWasChecked];
        [self setImage:self.checkedImage forState:UIControlStateNormal];
    } else {
        [checkDelegate checkButtonWasUnchecked];
        [self setImage:self.uncheckedImage forState:UIControlStateNormal];
    }
}

- (void) toggleWithBgView {
    isChecked = !isChecked;
    if(isChecked) {
        bgImgView.image = self.checkedImage;
    } else {
        bgImgView.image = self.uncheckedImage;
    }
}

- (void) manuallyCheck {
    isChecked = YES;
    bgImgView.image = self.checkedImage;
}

- (void) manuallyUncheck {
    isChecked = NO;
    bgImgView.image = self.uncheckedImage;
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

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
    return [self initWithFrame:frame isInitiallyChecked:isInitiallyChecked autoActionFlag:YES];
}

- (id)initWithFrame:(CGRect)frame isInitiallyChecked:(BOOL) isInitiallyChecked autoActionFlag:(BOOL) actionFlag {
    self = [super initWithFrame:frame];
    if (self) {
        self.isChecked = isInitiallyChecked;
        self.checkedImage = [UIImage imageNamed:@"check_checked_icon.png"];
        self.uncheckedImage = [UIImage imageNamed:@"check_unchecked_icon.png"];
        
        if(self.isChecked) {
            [self setImage:self.checkedImage forState:UIControlStateNormal];
        } else {
            [self setImage:self.uncheckedImage forState:UIControlStateNormal];
        }
        
        if(actionFlag) {
            [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title isInitiallyChecked:(BOOL) isInitiallyChecked {
    self = [super initWithFrame:frame];
    if (self) {
        self.isChecked = isInitiallyChecked;
        self.checkedImage = [UIImage imageNamed:@"checkbox_active.png"];
        self.uncheckedImage = [UIImage imageNamed:@"checkbox_normal.png"];
        
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - checkedImage.size.height)/2, checkedImage.size.width, checkedImage.size.height)];
        [self addSubview:bgImgView];
        
        if(self.isChecked) {
            bgImgView.image = self.checkedImage;
        } else {
            bgImgView.image = self.uncheckedImage;
        }

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgImgView.frame.size.width + 10, (self.frame.size.height - 16)/2, self.frame.size.width - bgImgView.frame.size.width - 10, 17)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [Util UIColorForHexColor:@"363e4f"];
        [titleLabel sizeToFit];
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

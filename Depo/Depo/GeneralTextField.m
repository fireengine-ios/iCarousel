//
//  GeneralTextField.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "GeneralTextField.h"
#import "Util.h"
#import "AppConstants.h"

@implementation GeneralTextField

- (id)initWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderVal {
    self = [super initWithFrame:frame];
    if (self) {
        self.background = [UIImage imageNamed:@"general_textfield_bg"];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentLeft;
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:15];
        UIColor *color = [Util UIColorForHexColor:@"363e4f"];
        UIColor *placeHolderColor = [Util UIColorForHexColor:@"cccccc"];
        self.textColor = color;
        self.font = currentFont;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderVal attributes:@{NSForegroundColorAttributeName: placeHolderColor, NSFontAttributeName: currentFont}];
        
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y + 10,
                      bounds.size.width - 40, bounds.size.height - 20);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
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

//
//  SingleCharField.m
//  Depo
//
//  Created by Mahir on 12/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SingleCharField.h"
#import "Util.h"
#import "AppConstants.h"

@implementation SingleCharField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.background = [UIImage imageNamed:@"bg_verif_digit.png"];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleNone;
        self.textAlignment = NSTextAlignmentCenter;
        
        UIFont *currentFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:30];
        UIColor *color = [Util UIColorForHexColor:@"8C8C8C"];
        self.textColor = color;
        self.font = currentFont;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(5, bounds.origin.y , bounds.size.width - 10 , bounds.size.height)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(5, bounds.origin.y , bounds.size.width - 10 , bounds.size.height)];
}

@end

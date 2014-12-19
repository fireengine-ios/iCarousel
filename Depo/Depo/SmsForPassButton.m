//
//  SmsForPassButton.m
//  Depo
//
//  Created by mahir tarlan on 12/26/13.
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "SmsForPassButton.h"
#import "Util.h"

@implementation SmsForPassButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
        titleLabel.text = NSLocalizedString(@"PassSmsTitle", @"");
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [Util UIColorForHexColor:@"989898"];
        [self addSubview:titleLabel];

        UILabel *passLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 20)];
        passLabel.text = @"SIFRE";
        passLabel.backgroundColor = [UIColor clearColor];
        passLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        passLabel.textAlignment = NSTextAlignmentRight;
        passLabel.textColor = [Util UIColorForHexColor:@"3C3C3C"];
        [self addSubview:passLabel];

        UIImage *iconImage = [UIImage imageNamed:@"sms_icon.png"];
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(passLabel.frame.size.width + 5, 20, iconImage.size.width, iconImage.size.height)];
        [self addSubview:iconImgView];
        iconImgView.image = iconImage;

        UILabel *receiverLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImgView.frame.origin.x + iconImgView.frame.size.width + 5, 20, 50, 20)];
        receiverLabel.text = @"2222";
        receiverLabel.backgroundColor = [UIColor clearColor];
        receiverLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        receiverLabel.textAlignment = NSTextAlignmentLeft;
        receiverLabel.textColor = [Util UIColorForHexColor:@"3C3C3C"];
        [self addSubview:receiverLabel];
    }
    return self;
}

- (id)initLongSmsWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
        titleLabel.text = @"TURKCELL ABONESİ DEĞİLSENİZ ŞİFRE ALMAK İÇİN";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [Util UIColorForHexColor:@"989898"];
        [self addSubview:titleLabel];
        
        UILabel *passLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 20)];
        passLabel.text = @"SIFRE";
        passLabel.backgroundColor = [UIColor clearColor];
        passLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        passLabel.textAlignment = NSTextAlignmentRight;
        passLabel.textColor = [Util UIColorForHexColor:@"3C3C3C"];
        [self addSubview:passLabel];
        
        UIImage *iconImage = [UIImage imageNamed:@"sms_icon.png"];
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(passLabel.frame.size.width + 5, 20, iconImage.size.width, iconImage.size.height)];
        [self addSubview:iconImgView];
        iconImgView.image = iconImage;
        
        UILabel *receiverLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImgView.frame.origin.x + iconImgView.frame.size.width + 5, 20, self.frame.size.width - iconImgView.frame.origin.x - iconImgView.frame.size.width - 5, 20)];
        receiverLabel.text = @"05327552222";
        receiverLabel.backgroundColor = [UIColor clearColor];
        receiverLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        receiverLabel.textAlignment = NSTextAlignmentLeft;
        receiverLabel.textColor = [Util UIColorForHexColor:@"3C3C3C"];
        [self addSubview:receiverLabel];
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

//
//  CustomAlertView.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "CustomAlertView.h"
#import "Util.h"
#import "CustomButton.h"
#import "SimpleButton.h"

@implementation CustomAlertView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withMessage:(NSString *) message withModalType:(ModalType) modalType {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        UIFont *messageFont = [UIFont fontWithName:@"Helvetica" size:18];
        
        int messageHeight = [Util calculateHeightForText:message forWidth:240 forFont:messageFont] + 20;
        
        int modalHeight = messageHeight + 140;

        UIView *modalView = [[UIView alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - modalHeight)/2, 280, modalHeight)];
        modalView.backgroundColor = [UIColor whiteColor];
        
        UIImage *iconImg = nil;
        switch (modalType) {
            case ModalTypeError:
                iconImg = [UIImage imageNamed:@"modal_carpibuton.png"];
                break;
            case ModalTypeInfo:
                iconImg = [UIImage imageNamed:@"modal_onay.png"];
                break;
            case ModalTypeSuccess:
                iconImg = [UIImage imageNamed:@"modal_pozirif.png"];
                break;
            case ModalTypeWarning:
                iconImg = [UIImage imageNamed:@"modal_uyari.png"];
                break;
                
            default:
                break;
        }
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 18, 24, 24)];
        iconImgView.image = iconImg;
        [modalView addSubview:iconImgView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 18, 160, 24)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:20];
        titleLabel.textColor = [Util UIColorForHexColor:@"3D3D3D"];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [modalView addSubview:titleLabel];

        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 240, messageHeight)];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.text = message;
        messageLabel.font = messageFont;
        messageLabel.textColor = [Util UIColorForHexColor:@"555555"];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.numberOfLines = 0;
        [modalView addSubview:messageLabel];
        
        SimpleButton *dismissButton = [[SimpleButton alloc] initWithFrame:CGRectMake(19, modalView.frame.size.height - 66, 242, 52) withTitle:@"Tamam" withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:22] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];

        [dismissButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:dismissButton];

        [self addSubview:modalView];
    }
    return self;
}

- (void) triggerDismiss {
    [delegate didDismissCustomAlert:self];
    [self removeFromSuperview];
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

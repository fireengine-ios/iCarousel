//
//  CustomConfirmView.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "CustomConfirmView.h"
#import "Util.h"
#import "CustomButton.h"

@implementation CustomConfirmView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withCancelTitle:(NSString *) cancelTitle withApproveTitle:(NSString *) approveTitle withMessage:(NSString *) message withModalType:(ModalType) modalType {
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
            case ModalTypeApprove:
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
        
        CustomButton *rejectButton = [[CustomButton alloc] initWithFrame:CGRectMake(19, modalView.frame.size.height - 66, 116, 52) withImageName:@"filter_gributon.png" withTitle:cancelTitle withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [rejectButton addTarget:self action:@selector(triggerCancel) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:rejectButton];
        
        CustomButton *approveButton = [[CustomButton alloc] initWithFrame:CGRectMake(145, modalView.frame.size.height - 66, 116, 52) withImageName:@"filter_saributon.png" withTitle:approveTitle withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"454545"]];
        [approveButton addTarget:self action:@selector(triggerApprove) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:approveButton];

        [self addSubview:modalView];
    }
    return self;
}

- (void) triggerCancel {
    [delegate didRejectCustomAlert:self];
    [self removeFromSuperview];
}

- (void) triggerApprove {
    [delegate didApproveCustomAlert:self];
    [self removeFromSuperview];
}

@end

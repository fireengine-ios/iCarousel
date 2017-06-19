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
#import "AppUtil.h"
#import "CheckButton.h"
#import "SimpleButton.h"

@interface CustomConfirmView (){
    CheckButton *dontShowAgain;
    NSString *dontShowCheckKey;
}
@end

@implementation CustomConfirmView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withCancelTitle:(NSString *) cancelTitle withApproveTitle:(NSString *) approveTitle withMessage:(NSString *) message withModalType:(ModalType) modalType {
    return [self initWithFrame:frame withTitle:title withCancelTitle:cancelTitle withApproveTitle:approveTitle withMessage:message withModalType:modalType shouldShowCheck:NO withCheckKey:nil];
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title withCancelTitle:(NSString *) cancelTitle withApproveTitle:(NSString *) approveTitle withMessage:(NSString *) message withModalType:(ModalType) modalType shouldShowCheck:(BOOL) checkFlag withCheckKey:(NSString *) checkKey {
    self = [super initWithFrame:frame];
    if (self) {
        dontShowCheckKey = checkKey;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        UIFont *messageFont = [UIFont fontWithName:@"Helvetica" size:18];
        
        int messageHeight = [Util calculateHeightForText:message forWidth:240 forFont:messageFont] + 20;
        
        int modalHeight = messageHeight + (checkFlag ? 200 : 140);
        
        UIView *modalView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 280)/2, (self.frame.size.height - modalHeight)/2, 280, modalHeight)];
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
        
        if(checkFlag) {
            dontShowAgain = [[CheckButton alloc] initWithFrame:CGRectMake(20, messageLabel.frame.origin.y + messageLabel.frame.size.height + 17, 25, 25) isInitiallyChecked:NO];
            [modalView addSubview:dontShowAgain];
            
            SimpleButton *dontShowButton = [[SimpleButton alloc] initWithFrame:CGRectMake(dontShowAgain.frame.origin.x + dontShowAgain.frame.size.width + 10, messageLabel.frame.origin.y + messageLabel.frame.size.height + 17, 120, 25) withTitle:NSLocalizedString(@"DontShowAgainMessage", @"") withAlignment:NSTextAlignmentLeft isUnderlined:NO];
            [dontShowButton addTarget:self action:@selector(dontShowTextClicked) forControlEvents:UIControlEventTouchUpInside];
            [modalView addSubview:dontShowButton];

        }
        
        int left = 19;
        int width = 116;
        if (cancelTitle.length > 0) {
            CustomButton *rejectButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, modalView.frame.size.height - 66, width, 52)];
            [rejectButton setTitle:cancelTitle forState:UIControlStateNormal];
            rejectButton.backgroundColor = [UIColor whiteColor];
            rejectButton.layer.borderColor = [Util UIColorForHexColor:@"e9ebef"].CGColor;
            rejectButton.layer.borderWidth = 1.0f;
            rejectButton.layer.cornerRadius = 5.0f;
            [rejectButton setTitleColor:[Util UIColorForHexColor:@"292F3E"] forState:UIControlStateNormal];
            rejectButton.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
            [rejectButton addTarget:self action:@selector(triggerCancel) forControlEvents:UIControlEventTouchUpInside];
            [modalView addSubview:rejectButton];
            
            left = 145;
        }
        else {
            width = 242;
        }
        
        CustomButton *approveButton = [[CustomButton alloc] initWithFrame:CGRectMake(left, modalView.frame.size.height - 66, width, 52)];
        [approveButton setTitle:approveTitle forState:UIControlStateNormal];
        approveButton.backgroundColor = [Util UIColorForHexColor:@"FEDB13"];
        approveButton.layer.cornerRadius = 5.0f;
        [approveButton setTitleColor:[Util UIColorForHexColor:@"292F3E"] forState:UIControlStateNormal];
        approveButton.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        [approveButton addTarget:self action:@selector(triggerApprove) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:approveButton];

        [self addSubview:modalView];
    }
    return self;
}

- (void) dontShowTextClicked {
}

- (void) checkBeforeDismiss {
    if(dontShowAgain && dontShowCheckKey) {
        if(dontShowAgain.isChecked){
            [AppUtil writeDoNotShowAgainFlagForKey:dontShowCheckKey];
        }
    }
}

- (void) triggerCancel {
    [self checkBeforeDismiss];
    
    [delegate didRejectCustomAlert:self];
    [self removeFromSuperview];
}

- (void) triggerApprove {
    [self checkBeforeDismiss];

    [delegate didApproveCustomAlert:self];
    [self removeFromSuperview];
}

@end

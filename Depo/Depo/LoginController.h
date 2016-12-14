//
//  LoginController.h
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"
#import "RequestTokenDao.h"
#import "RequestCaptchaDao.h"
#import <MessageUI/MessageUI.h>
#import "CheckButton.h"
#import "SimpleButton.h"
#import "CustomButton.h"

@interface LoginController : MyViewController <UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate> {

    RequestTokenDao *tokenDao;
    RequestCaptchaDao *captchaDao;
    
    NSString *msisdnValue;
    NSString *passValue;
    NSString *captchaUniqueId;
    
    CheckButton *rememberMe;
}

@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) SimpleButton *loginButton;
@property (nonatomic, strong) UIView* captchaContainer;
@property (nonatomic, strong) UIImageView *captchaView;
//@property (nonatomic, strong) CustomButton *refreshButton;
@property (nonatomic, strong) LoginTextfield *msisdnField;
@property (nonatomic, strong) LoginTextfield *passField;
@property (nonatomic, strong) LoginTextfield *captchaField;
@property (nonatomic, strong) UIView *forgotPassView;

@end

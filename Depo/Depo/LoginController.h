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
#import <MessageUI/MessageUI.h>
#import "CheckButton.h"

@interface LoginController : MyViewController <UITextFieldDelegate, MFMessageComposeViewControllerDelegate> {
    RequestTokenDao *tokenDao;
    NSString *msisdnValue;
    NSString *passValue;
    CheckButton *rememberMe;
}

@property (nonatomic, strong) LoginTextfield *msisdnField;
@property (nonatomic, strong) LoginTextfield *passField;

@end

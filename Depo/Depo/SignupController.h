//
//  SignupController.h
//  Depo
//
//  Created by Mahir on 08/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"
#import "SignupDao.h"

@interface SignupController : MyViewController <UITextFieldDelegate> {
    NSString *msisdnValue;
    NSString *emailValue;
    NSString *passwordValue;
    NSString *passwordRepeatValue;

    SignupDao *signupDao;
}

@property (nonatomic, strong) LoginTextfield *msisdnField;
@property (nonatomic, strong) LoginTextfield *emailField;
@property (nonatomic, strong) LoginTextfield *passwordField;
@property (nonatomic, strong) LoginTextfield *passwordRepeatField;

@end

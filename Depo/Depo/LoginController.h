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

@interface LoginController : MyViewController <UITextFieldDelegate> {
    RequestTokenDao *tokenDao;
    NSString *msisdnValue;
    NSString *passValue;
}

@property (nonatomic, strong) LoginTextfield *msisdnField;
@property (nonatomic, strong) LoginTextfield *passField;

@end

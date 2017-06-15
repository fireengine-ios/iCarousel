//
//  EmailChangeController.h
//  Depo
//
//  Created by Mahir Tarlan on 23/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "UpdateEmailDao.h"
#import "LoginTextfield.h"
#import "CustomConfirmView.h"

@interface EmailChangeController : MyViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, CustomConfirmDelegate> {
    UpdateEmailDao *emailDao;
}

@property (nonatomic, strong) LoginTextfield *emailField;


@end

//
//  EmailEntryController.h
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "UpdateEmailDao.h"
#import "LoginTextfield.h"
#import "CustomConfirmView.h"

@interface EmailEntryController : MyViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, CustomConfirmDelegate> {
    UpdateEmailDao *emailDao;
}

@property (nonatomic, strong) LoginTextfield *emailField;

@end

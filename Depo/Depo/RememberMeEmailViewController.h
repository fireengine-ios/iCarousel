//
//  RememberMeEmailViewController.h
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"
#import "RequestCaptchaDao.h"
#import "ForgotPassDao.h"
#import "CustomButton.h"

@interface RememberMeEmailViewController : MyViewController <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    RequestCaptchaDao *captchaDao;
    ForgotPassDao *forgotPassDao;

    NSString *captchaUniqueId;
}

@property (nonatomic, strong) LoginTextfield *emailField;
@property (nonatomic, strong) LoginTextfield *captchaField;
@property (nonatomic, strong) UIImageView *captchaView;
@property (nonatomic, strong) CustomButton *refreshButton;

@end

//
//  RememberMeEmailViewController.m
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RememberMeEmailViewController.h"
#import "Util.h"
#import "CustomLabel.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface RememberMeEmailViewController ()

@end

@implementation RememberMeEmailViewController

@synthesize emailField;
@synthesize captchaField;
@synthesize captchaView;
@synthesize refreshButton;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"ForgotPassTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        captchaDao = [[RequestCaptchaDao alloc] init];
        captchaDao.delegate = self;
        captchaDao.successMethod = @selector(captchaSuccessCallback:);
        captchaDao.failMethod = @selector(captchaFailCallback:);

        forgotPassDao = [[ForgotPassDao alloc] init];
        forgotPassDao.delegate = self;
        forgotPassDao.successMethod = @selector(forgotPassSuccessCallback:);
        forgotPassDao.failMethod = @selector(forgotPassFailCallback:);
        
        CustomLabel *topInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"AlmostThere", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:topInfoLabel];
        
        UIImage *iconImg = [UIImage imageNamed:@"icon_dialog_positive.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - iconImg.size.width)/2, topInfoLabel.frame.origin.y + topInfoLabel.frame.size.height + 10, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self.view addSubview:iconView];
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, iconView.frame.origin.y + iconView.frame.size.height + 10, self.view.frame.size.width-40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"EmailFieldRegistrationInfo", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:subInfoLabel];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, subInfoLabel.frame.origin.y + subInfoLabel.frame.size.height + 10, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];
        
        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"EmailPlaceholder", @"")];
        emailField.delegate = self;
        [self.view addSubview:emailField];
        
        captchaView = [[UIImageView alloc] initWithFrame:CGRectMake(20, emailField.frame.origin.y + emailField.frame.size.height + 20, 200, 50)];
        [self.view addSubview:captchaView];
        
        refreshButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 38, emailField.frame.origin.y + emailField.frame.size.height + 20, 18, 18) withImageName:@"icon_verif_refresh.png"];
        refreshButton.hidden = YES;
        [refreshButton addTarget:self action:@selector(loadCaptcha) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:refreshButton];

        captchaField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, captchaView.frame.origin.y + captchaView.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"CaptchaPlaceholder", @"")];
        captchaField.delegate = self;
        [self.view addSubview:captchaField];

        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, captchaField.frame.origin.y + captchaField.frame.size.height + 10, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(forgotPassClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:okButton];

        [self performSelector:@selector(loadCaptcha) withObject:nil afterDelay:1.0f];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void) loadCaptcha {
    captchaUniqueId = [[NSUUID UUID] UUIDString];
    [captchaDao requestCaptchaForType:@"IMAGE" andId:captchaUniqueId];
}

- (void) forgotPassClicked {
    if([emailField.text length] == 0 || ![Util isValidEmail:emailField.text]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailFormatErrorMessage", @"")];
        return;
    }
    if([captchaField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaFieldErrorMessage", @"")];
        return;
    }
    
    [self.view endEditing:YES];
    
    [forgotPassDao requestNotifyForgotPassWithEmail:emailField.text withCaptchaId:captchaUniqueId withCaptchaValue:captchaField.text];
    [self showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) captchaSuccessCallback:(UIImage *) captchaImg {
    captchaView.image = captchaImg;
    refreshButton.hidden = NO;
}

- (void) captchaFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) forgotPassSuccessCallback:(NSDictionary *) resultDict {
    [self hideLoading];
    NSString *errorMsg = [resultDict objectForKey:@"errorMsg"];
    if(errorMsg != nil && ![errorMsg isKindOfClass:[NSNull class]]) {
        if([errorMsg hasPrefix:@"User can not change password"]) {
            [self showInfoAlertWithMessage:NSLocalizedString(@"EmailError2222", @"")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
    }
    [self showInfoAlertWithMessage:NSLocalizedString(@"PassSentToEmail", @"")];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) forgotPassFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
    
    captchaField.text = @"";
    [self loadCaptcha];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [emailField resignFirstResponder];
    [captchaField resignFirstResponder];
    return YES;
}

-(void)keyboardWillShow {
    if(captchaField.isFirstResponder) {
        if (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
        }
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    } else {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end

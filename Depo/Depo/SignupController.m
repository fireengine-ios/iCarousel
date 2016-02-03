//
//  SignupController.m
//  Depo
//
//  Created by Mahir on 08/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SignupController.h"
#import "CustomButton.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppConstants.h"
#import "OTPController.h"
#import "EmailValidationResultController.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface SignupController ()

@end

@implementation SignupController

@synthesize msisdnField;
@synthesize emailField;
@synthesize passwordField;
@synthesize passwordRepeatField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SignUp", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        signupDao = [[SignupDao alloc] init];
        signupDao.delegate = self;
        signupDao.successMethod = @selector(signupSuccessCallback:);
        signupDao.failMethod = @selector(signupFailCallback:);
        
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 30, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [self.view addSubview:msisdnLabel];
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, 55, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        msisdnField.delegate = self;
        msisdnField.placeholder = @"5xxxxxxxxx";
        [self.view addSubview:msisdnField];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 110, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];
        
        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, 135, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"EmailPlaceholder", @"")];
        emailField.delegate = self;
        [self.view addSubview:emailField];

        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 190, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
        [self.view addSubview:passLabel];
        
        passwordField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, 215, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"PasswordPlaceholder", @"")];
        passwordField.delegate = self;
        [self.view addSubview:passwordField];

        CustomLabel *passRepeatLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 270, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordRepeatTitle", @"")];
        [self.view addSubview:passRepeatLabel];
        
        passwordRepeatField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, 295, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"PasswordRepeatPlaceholder", @"")];
        passwordRepeatField.delegate = self;
        [self.view addSubview:passwordRepeatField];

        SimpleButton *signupButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 134, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"SignUp", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [signupButton addTarget:self action:@selector(signupClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:signupButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [self.view endEditing:YES];
}

- (void) signupClicked {
    if ([msisdnValue length] > 0)
        msisdnValue = [[msisdnValue substringToIndex:1] isEqualToString:@"0"] ? [msisdnValue substringFromIndex:1] : msisdnValue;
    
    if([msisdnField.text length] != 10) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnFormatErrorMessage", @"")];
        return;
    }
    if([passwordField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PassFormatErrorMessage", @"")];
        return;
    }
    if([passwordRepeatField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PassRepeatFormatErrorMessage", @"")];
        return;
    }
    if([emailField.text length] == 0 || ![Util isValidEmail:emailField.text]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailFormatErrorMessage", @"")];
        return;
    }
    if(![passwordRepeatField.text isEqualToString:passwordField.text]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PassMismatchErrorMessage", @"")];
        return;
    }
    
    APPDELEGATE.session.signupReferenceMsisdn = msisdnField.text;
    APPDELEGATE.session.signupReferenceEmail = emailField.text;
    APPDELEGATE.session.signupReferencePassword = passwordField.text;

    [self.view endEditing:YES];
    
    [signupDao requestTriggerSignupForEmail:emailField.text forPhoneNumber:msisdnField.text withPassword:passwordField.text];
    [self showLoading];
}

- (void) signupSuccessCallback:(NSDictionary *) signupResult {
    [self hideLoading];
    NSLog(@"Signup Result: %@", signupResult);
    NSString *signupStatus = [signupResult objectForKey:@"status"];
    if([[signupStatus uppercaseString] isEqualToString:@"OK"]) {
        NSDictionary *valueDict = [signupResult objectForKey:@"value"];
        NSString *action = [valueDict objectForKey:@"action"];
        NSString *referenceToken = [valueDict objectForKey:@"referenceToken"];
        NSNumber *remainingTimeInMinutes = [valueDict objectForKey:@"remainingTimeInMinutes"];
        NSNumber *expectedInputLength = [valueDict objectForKey:@"expectedInputLength"];
        
        APPDELEGATE.session.signupReferenceToken = referenceToken;
        
        if([action isEqualToString:POST_SIGNUP_ACTION_OTP]) {
            OTPController *otp = [[OTPController alloc] initWithRemainingTimeInMinutes:[remainingTimeInMinutes intValue] andInputLength:[expectedInputLength intValue]];
            [self.navigationController pushViewController:otp animated:YES];
        } else if([action isEqualToString:POST_SIGNUP_ACTION_EMAIL]) {
            EmailValidationResultController *emailController = [[EmailValidationResultController alloc] initWithEmailVal:emailValue];
            [self.navigationController pushViewController:emailController animated:YES];
        } else {
            [self showInfoAlertWithMessage:NSLocalizedString(@"SignupSuccess", @"")];
            return;
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(signupStatus, @"")];
        return;
    }
}

- (void) signupFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillShow {
    if(passwordField.isFirstResponder || passwordRepeatField.isFirstResponder) {
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [msisdnField resignFirstResponder];
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [passwordRepeatField resignFirstResponder];
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end

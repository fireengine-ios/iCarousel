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
#import "TermsController.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface SignupController () {
    SimpleButton *signupButton;
}
@end

@implementation SignupController

@synthesize msisdnField;
@synthesize emailField;
@synthesize passwordField;
@synthesize passwordRepeatField;
@synthesize eulaCheck;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SignUp", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        signupDao = [[SignupDao alloc] init];
        signupDao.delegate = self;
        signupDao.successMethod = @selector(signupSuccessCallback:);
        signupDao.failMethod = @selector(signupFailCallback:);
        
        float topIndex = (IS_IPHONE_4_OR_LESS ? 10 : 30);
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [self.view addSubview:msisdnLabel];
        
        topIndex += 25;
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        msisdnField.delegate = self;
        msisdnField.placeholder = @"5xxxxxxxxx";
        [self.view addSubview:msisdnField];

        topIndex += 55;

        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];

        topIndex += 25;

        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"EmailPlaceholder", @"")];
        emailField.delegate = self;
        [self.view addSubview:emailField];

        topIndex += 55;

        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
        [self.view addSubview:passLabel];
        
        topIndex += 25;

        passwordField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"PasswordPlaceholder", @"")];
        passwordField.delegate = self;
        [self.view addSubview:passwordField];

        topIndex += 55;

        CustomLabel *passRepeatLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordRepeatTitle", @"")];
        [self.view addSubview:passRepeatLabel];

        topIndex += 25;

        passwordRepeatField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"PasswordRepeatPlaceholder", @"")];
        passwordRepeatField.delegate = self;
        [self.view addSubview:passwordRepeatField];

        topIndex += IS_IPHONE_4_OR_LESS ? 50 : 65;

        eulaCheck = [[CheckButton alloc] initWithFrame:CGRectMake(25, topIndex, 25, 25) isInitiallyChecked:NO];
        eulaCheck.checkDelegate = self;
        [self.view addSubview:eulaCheck];

        SimpleButton *eulaButton = [[SimpleButton alloc] initWithFrame:CGRectMake(eulaCheck.frame.origin.x + eulaCheck.frame.size.width + 10, topIndex, self.view.frame.size.width - 80, 25) withTitle:NSLocalizedString(@"TermsButtonTitle", @"") withAlignment:NSTextAlignmentLeft isUnderlined:YES];
        [eulaButton addTarget:self action:@selector(eulaClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:eulaButton];

        CGRect signupButtonRect = CGRectMake(20, self.view.frame.size.height - 134, self.view.frame.size.width - 40, 50);
        if(IS_IPHONE_4_OR_LESS) {
            signupButtonRect = CGRectMake(20, self.view.frame.size.height - 124, self.view.frame.size.width - 40, 50);
        }
        
        signupButton = [[SimpleButton alloc] initWithFrame:signupButtonRect withTitle:NSLocalizedString(@"SignUp", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
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

- (void) eulaClicked {
    TermsController *terms = [[TermsController alloc] initWithCheckEnabled:NO];
    [self.navigationController pushViewController:terms animated:YES];
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
//    if ([msisdnValue length] > 0)
//        msisdnValue = [[msisdnValue substringToIndex:1] isEqualToString:@"0"] ? [msisdnValue substringFromIndex:1] : msisdnValue;
    
    if([msisdnField.text length] < 10) {
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
    if(!eulaCheck.isChecked) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"AcceptTermsWarning", @"")];
        return;
    }
    
    APPDELEGATE.session.signupReferenceMsisdn = msisdnField.text;
    APPDELEGATE.session.signupReferenceEmail = emailField.text;
    APPDELEGATE.session.signupReferencePassword = passwordField.text;

    [self.view endEditing:YES];
    
    NSString *confirmMessage = [NSString stringWithFormat:NSLocalizedString(@"EmailConfirmMessage", @""), emailField.text];
    CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Approve", @"") withCancelTitle:NSLocalizedString(@"EmailConfirmUpdate", @"") withApproveTitle:NSLocalizedString(@"EmailConfirmContinue", @"") withMessage:confirmMessage withModalType:ModalTypeApprove];
    confirm.delegate = self;
    [APPDELEGATE showCustomConfirm:confirm];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
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
        
        APPDELEGATE.session.otpReferenceToken = referenceToken;
        
        if([action isEqualToString:POST_SIGNUP_ACTION_OTP]) {
            OTPController *otp = [[OTPController alloc] initWithRemainingTimeInMinutes:[remainingTimeInMinutes intValue] andInputLength:[expectedInputLength intValue] withType:MsisdnUpdateTypeSignup];
            [self.navigationController pushViewController:otp animated:YES];
        } else if([action isEqualToString:POST_SIGNUP_ACTION_EMAIL]) {
            EmailValidationResultController *emailController = [[EmailValidationResultController alloc] initWithEmailVal:emailValue];
            [self.navigationController pushViewController:emailController animated:YES];
        } else {
            [self showInfoAlertWithMessage:NSLocalizedString(@"SignupSuccess", @"")];
            return;
        }
    } else if([[signupStatus uppercaseString] isEqualToString:@"INVALID_PASSWORD"]){
        NSDictionary *detailDict = [signupResult objectForKey:@"value"];
        NSString *errorReason = [detailDict objectForKey:@"reason"];
        if(errorReason != nil && [errorReason isKindOfClass:[NSString class]]) {
            [self showErrorAlertWithMessage:NSLocalizedString(errorReason, @"")];
        } else {
            [self showErrorAlertWithMessage:NSLocalizedString(signupStatus, @"")];
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(signupStatus, @"")];
        if([signupStatus isEqualToString:@"VERIFY_EXISTING_EMAIL"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
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

- (void) checkButtonWasChecked {
}

- (void) checkButtonWasUnchecked {
}

@end

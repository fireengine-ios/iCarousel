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
#import "Eula.h"
#import "MPush.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface SignupController () {
    SimpleButton *signupButton;
    Eula *eula;
    UIScrollView* container;
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
        self.title = NSLocalizedString(@"SignUpButtonTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        signupDao = [[SignupDao alloc] init];
        signupDao.delegate = self;
        signupDao.successMethod = @selector(signupSuccessCallback:);
        signupDao.failMethod = @selector(signupFailCallback:);
        
        eulaDao = [[EulaDao alloc] init];
        eulaDao.delegate = self;
        eulaDao.successMethod = @selector(eulaReadSuccessCallback:);
        eulaDao.failMethod = @selector(eulaReadFailCallback:);
        
        float topIndex = IS_IPAD ? 100 : (IS_IPHONE_4_OR_LESS ? 10 : 20);
        float fieldWidth = 280;
        
        container = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 20);
        [self.view addSubview:container];
        
        UIImage *logoImage = [UIImage imageNamed:@"icon_lifebox.png"];
        UIImageView *logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoImage.size.width)/2, topIndex, logoImage.size.width, logoImage.size.height)];
        logoImgView.image = logoImage;
        [container addSubview:logoImgView];
        
        topIndex += logoImage.size.height+50;
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [container addSubview:msisdnLabel];
        
        topIndex += 5;
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 43) withPlaceholder:/*NSLocalizedString(@"MsisdnPlaceholder", @"")*/@""];
        msisdnField.delegate = self;
        [msisdnField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        msisdnField.placeholder = @"5xxxxxxxxx";
//        msisdnField.keyboardType = UIKeyboardTypePhonePad;
        [container addSubview:msisdnField];

        topIndex += 55;

        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FormEmailTitle", @"")];
        [container addSubview:emailLabel];

        topIndex += 5;

        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 43) withPlaceholder:/*NSLocalizedString(@"EmailPlaceholder", @"")*/@""];
        emailField.delegate = self;
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        [container addSubview:emailField];

        topIndex += 55;

        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
        [container addSubview:passLabel];
        
        topIndex += 5;

        passwordField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 43) withPlaceholder:/*NSLocalizedString(@"PasswordPlaceholder", @"")*/@""];
        passwordField.delegate = self;
        [container addSubview:passwordField];

        topIndex += 55;

        CustomLabel *passRepeatLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordRepeatTitle", @"")];
        [container addSubview:passRepeatLabel];

        topIndex += 5;

        passwordRepeatField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 43) withPlaceholder:/*NSLocalizedString(@"PasswordRepeatPlaceholder", @"")*/@""];
        passwordRepeatField.delegate = self;
        [container addSubview:passwordRepeatField];

        topIndex += IS_IPHONE_4_OR_LESS ? 50 : 65;

        eulaCheck = [[CheckButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2 + 5, topIndex, 25, 25) isInitiallyChecked:NO];
        eulaCheck.checkDelegate = self;
        [container addSubview:eulaCheck];

        SimpleButton *eulaButton = [[SimpleButton alloc] initWithFrame:CGRectMake(eulaCheck.frame.origin.x + eulaCheck.frame.size.width + 10, topIndex, fieldWidth - 40, 25) withTitle:NSLocalizedString(@"TermsButtonTitle", @"") withAlignment:NSTextAlignmentLeft isUnderlined:YES];
        [eulaButton addTarget:self action:@selector(eulaClicked) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:eulaButton];

        CGRect signupButtonRect = CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60);
        if(IS_IPAD) {
            signupButtonRect = CGRectMake((self.view.frame.size.width - fieldWidth)/2, eulaButton.frame.origin.y + eulaButton.frame.size.height + 30, fieldWidth, 50);
        } else if(IS_IPHONE_4_OR_LESS) {
            signupButtonRect = CGRectMake((self.view.frame.size.width - fieldWidth)/2, self.view.frame.size.height - 124, fieldWidth, 50);
        }
        
        signupButton = [[SimpleButton alloc] initWithFrame:signupButtonRect withTitle:NSLocalizedString(@"SignUpButton", @"") withTitleColor:[Util UIColorForHexColor:@"ffffff"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3FB0E8"] withBgColor:[Util UIColorForHexColor:@"3FB0E8"] withCornerRadius:0];
        [signupButton addTarget:self action:@selector(signupClicked) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:signupButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
        [eulaDao requestEulaForLocale:[Util readLocaleCode]];
        [self showLoading];
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
    
    NSString *trimmedString = [[msisdnField.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    msisdnValue = trimmedString;
    
    if([msisdnValue length] < 10) {
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
    CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"EmailConfirmUpdate", @"") withApproveTitle:NSLocalizedString(@"EmailConfirmContinue", @"") withMessage:confirmMessage withModalType:ModalTypeApprove];
    confirm.delegate = self;
    [APPDELEGATE showCustomConfirm:confirm];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
    [[CurioSDK shared] sendEvent:@"Signup>EmailConfirm" eventValue:@"Denied"];
    [MPush hitTag:@"Signup>EmailConfirm" withValue:@"Denied"];
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
    [[CurioSDK shared] sendEvent:@"Signup>EmailConfirm" eventValue:@"Approved"];
    [MPush hitTag:@"Signup>EmailConfirm" withValue:@"Approved"];
    
    [signupDao requestTriggerSignupForEmail:emailField.text forPhoneNumber:msisdnField.text withPassword:passwordField.text withEulaId:eula ? eula.eulaId : 0];
    [self showLoading];
}

- (void) signupSuccessCallback:(NSDictionary *) signupResult {
    [self hideLoading];
    NSLog(@"Signup Result: %@", signupResult);
    NSString *signupStatus = [signupResult objectForKey:@"status"];
    if(signupStatus != nil && ![signupStatus isKindOfClass:[NSNull class]] && [signupStatus isKindOfClass:[NSString class]]) {
        if([[signupStatus uppercaseString] isEqualToString:@"OK"]) {
            [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"Success"];
            [MPush hitTag:@"Signup>First" withValue:@"Success"];
            
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
            [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"InvalidPassword"];
            [MPush hitTag:@"Signup>First" withValue:@"InvalidPassword"];
            
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
                [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"VerifyExistingEmail"];
                [MPush hitTag:@"Signup>First" withValue:@"VerifyExistingEmail"];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"Fail"];
                [MPush hitTag:@"Signup>First" withValue:@"Fail"];
            }
        }
    } else {
        [self showErrorAlertWithMessage:GENERAL_ERROR_MESSAGE];
        [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"Fail"];
        [MPush hitTag:@"Signup>First" withValue:@"Fail"];
    }
}

- (void) innerTriggerBack {
    [[CurioSDK shared] sendEvent:@"SignUp>First" eventValue:@"Back"];
    [MPush hitTag:@"Signup>First" withValue:@"Back"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) signupFailCallback:(NSString *) errorMessage {
    [[CurioSDK shared] sendEvent:@"Signup>First" eventValue:@"Fail"];
    [MPush hitTag:@"Signup>First" withValue:@"Fail"];
    
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(innerTriggerBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"SignupController viewDidLoad");

    [[CurioSDK shared] sendEvent:@"Signup>First" eventValue:@"Enter"];
    [MPush hitTag:@"Signup>First" withValue:@"Enter"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillShow {
    if(passwordField.isFirstResponder || passwordRepeatField.isFirstResponder) {
//        if (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
//        }
    }
}

-(void)keyboardWillHide {
//    if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
//    }
}

-(void)setViewMovedUp:(BOOL)movedUp {
    if (movedUp) {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 210);
        [container setContentOffset:CGPointMake(0,  210) animated:YES];
    }
    else {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        [container setContentOffset:CGPointZero animated:YES];
    }

//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    
//    CGRect rect = self.view.frame;
//    if (movedUp) {
//        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
//        rect.size.height += kOFFSET_FOR_KEYBOARD;
//    } else {
//        rect.origin.y += kOFFSET_FOR_KEYBOARD;
//        rect.size.height -= kOFFSET_FOR_KEYBOARD;
//    }
//    self.view.frame = rect;
//    
//    [UIView commitAnimations];
}

- (void) textFieldDidChange:(UITextField *) textField {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    NSString* callingCode = @"+(90)";
    if (isNumeric) {
        if([[Util readLocaleCode] isEqualToString:@"uk"] || [[Util readLocaleCode] isEqualToString:@"ru"] ) {
            callingCode = @"+(380)";
            callingCode = [callingCode stringByAppendingString:textField.text];
            msisdnField.text = callingCode;
        }
        else {
            callingCode = [callingCode stringByAppendingString:textField.text];
            msisdnField.text = callingCode;
        }
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [msisdnField resignFirstResponder];
 
    if(!textField.secureTextEntry) {
        if([[Util readLocaleCode] isEqualToString:@"tr"] || [[Util readLocaleCode] isEqualToString:@"en"]) {
            NSRange range = [textField.text rangeOfString:@")" options:NSBackwardsSearch];
            if (range.location != NSNotFound) {
                NSString *callingCode = [textField.text substringToIndex:range.location + 1];
                if([callingCode isEqualToString:@"+(90)"]) {
                    NSString *number = [textField.text substringFromIndex:range.location + range.length];
                    if ([number hasPrefix:@"0"] && [number length] > 1) {
                        number = [number substringFromIndex:1];
                        NSString *editedNumber = [callingCode stringByAppendingString:number];
                        textField.text = editedNumber;
                    }
                }
            }
        }
    }
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

- (void) eulaReadSuccessCallback:(Eula *) eulaRead {
    eula = eulaRead;
    [self hideLoading];
}

- (void) eulaReadFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

@end

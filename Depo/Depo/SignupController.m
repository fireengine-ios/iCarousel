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
#import "CountrySelectionController.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface SignupController () {
    SimpleButton *signupButton;
    Eula *eula;
    UIScrollView* container;
}
@property (nonatomic) CountrySelectionController *countrySelectionController;
@property (nonatomic, strong) UIButton *countryCodeButton;
@property (nonatomic) NSString *selectedCountry;
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
        
        CGFloat verticalPadding = 70.0f;
        if (IS_IPHONE_5) {
            verticalPadding = 50.0f;
        } else if (IS_IPHONE_4_OR_LESS) {
            verticalPadding = 50.0f;
        }
        
        float topIndex = IS_IPAD ? (self.view.frame.size.height - 300)/2 - 100 : (IS_IPHONE_4_OR_LESS ? 10 : 20);
        float fieldWidth = self.view.frame.size.width - 40;
        if (IS_IPAD) {
            fieldWidth = 480;
        }
        container = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 20);
        [self.view addSubview:container];
        
        UIImage *logoImage = [UIImage imageNamed:@"icon_lifebox.png"];
        UIImageView *logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoImage.size.width)/2, topIndex, logoImage.size.width, logoImage.size.height)];
        logoImgView.image = logoImage;
        [container addSubview:logoImgView];
        
        topIndex += logoImage.size.height + (IS_IPHONE_4_OR_LESS ? 20 : verticalPadding);
        
        
        _countryCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_countryCodeButton setFrame:CGRectMake(18, topIndex +11, 68, 32)];
        [_countryCodeButton setBackgroundImage:[UIImage imageNamed:@"combobg.png"] forState:UIControlStateNormal];
        [_countryCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_countryCodeButton addTarget:self action:@selector(goCountryCodepage:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:_countryCodeButton];

        NSString *currentCode;
        NSString *currentLocale = [Util readLocaleCode];
        if([currentLocale isEqualToString:@"uk"] || [currentLocale isEqualToString:@"ru"]) {
            [_countryCodeButton setTitle:@"+90" forState:UIControlStateNormal];
            currentCode = @"+380";
            self.selectedCountry = @"UK";
        } else if ([currentLocale isEqualToString:@"ar"]) {
            currentCode = @"+966";
            self.selectedCountry = @"AR";
        } else if ([currentLocale isEqualToString:@"de"]) {
            currentCode = @"+49";
            self.selectedCountry = @"DE";
        } else {
            currentCode = @"+90";
            self.selectedCountry = @"TR";
        }
        [_countryCodeButton setTitle:currentCode forState:UIControlStateNormal];

        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(24, 0, 8, 4)];
        CGPoint center = arrow.center;
        center.y = _countryCodeButton.center.y;
        arrow.center = center;
        arrow.image = [UIImage imageNamed:@"icon_dropdown.png"];
        [container addSubview:arrow];
        
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2 +68,
                                                                       topIndex,
                                                                       fieldWidth -68,
                                                                       43)
                                            withPlaceholder:NSLocalizedString(@"MsisdnPlaceholderNew", @"")];
        msisdnField.delegate = self;
        [msisdnField addTarget:self action:@selector(msisdnFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        msisdnField.placeholder = @"5xxxxxxxxx";
        msisdnField.keyboardType = UIKeyboardTypePhonePad;
        msisdnField.isAccessibilityElement = YES;
        msisdnField.accessibilityIdentifier = @"msisdnFieldSignUp";
        [container addSubview:msisdnField];
        
        if (IS_IPAD) {
            _countryCodeButton.frame = CGRectMake((msisdnField.frame.origin.x - _countryCodeButton.frame.size.width), _countryCodeButton.frame.origin.y, _countryCodeButton.frame.size.width, _countryCodeButton.frame.size.height);
            arrow.frame = CGRectMake((_countryCodeButton.frame.origin.x + 6), arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        }

        topIndex += verticalPadding;

//        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FormEmailTitle", @"")];
//        [container addSubview:emailLabel];

        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 43)
                                           withPlaceholder:NSLocalizedString(@"EmailPlaceholderNew", @"")];
        emailField.delegate = self;
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        emailField.isAccessibilityElement = YES;
        emailField.accessibilityIdentifier = @"emailFieldSignUp";
        [container addSubview:emailField];

        topIndex += verticalPadding;

//        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
//        [container addSubview:passLabel];

        passwordField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2,
                                                                               topIndex,
                                                                               fieldWidth,
                                                                               43)
                                                    withPlaceholder:NSLocalizedString(@"PasswordPlaceholder", @"")];
        passwordField.delegate = self;
        passwordField.isAccessibilityElement = YES;
        passwordField.accessibilityIdentifier = @"passwordFieldSignUp";
        [container addSubview:passwordField];

        topIndex += verticalPadding;

//        CustomLabel *passRepeatLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2, topIndex, fieldWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordRepeatTitle", @"")];
//        [container addSubview:passRepeatLabel];

        passwordRepeatField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2,
                                                                                     topIndex,
                                                                                     fieldWidth,
                                                                                     43)
                                                          withPlaceholder:[NSLocalizedString(@"PasswordRepeatPlaceholder", @"") capitalizedString]];
        passwordRepeatField.delegate = self;
        passwordRepeatField.isAccessibilityElement = YES;
        passwordRepeatField.accessibilityIdentifier = @"passwordRepeatFieldSignUp";
        [container addSubview:passwordRepeatField];

        topIndex += IS_IPHONE_4_OR_LESS ? 50 : 65;

        eulaCheck = [[CheckButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - fieldWidth)/2 + 5, topIndex, 25, 25)
                                             withTitle:@""
                                    isInitiallyChecked:NO];
        eulaCheck.checkDelegate = self;
        eulaCheck.isAccessibilityElement = YES;
        eulaCheck.accessibilityIdentifier = @"eulaCheck";
        [container addSubview:eulaCheck];

        SimpleButton *eulaButton = [[SimpleButton alloc] initWithFrame:CGRectMake(eulaCheck.frame.origin.x + eulaCheck.frame.size.width + 10,
                                                                                  topIndex,
                                                                                  fieldWidth - 40,
                                                                                  25)
                                                             withTitle:NSLocalizedString(@"TermsButtonTitle", @"")
                                                         withAlignment:NSTextAlignmentLeft
                                                          isUnderlined:YES];
        [eulaButton addTarget:self action:@selector(eulaClicked) forControlEvents:UIControlEventTouchUpInside];
        eulaButton.isAccessibilityElement = YES;
        eulaButton.accessibilityIdentifier = @"eulaButtonSignUp";
        [container addSubview:eulaButton];

        CGFloat btnWidth = 200.0f, btnHeight = 40.0f;
        CGRect signupButtonRect = CGRectMake((self.view.frame.size.width - btnWidth) /2,
                                             self.view.frame.size.height - (btnHeight * 2) - 64,
                                             btnWidth,
                                             btnHeight);
        if(IS_IPAD) {
            signupButtonRect = CGRectMake((self.view.frame.size.width - fieldWidth)/2, eulaButton.frame.origin.y + eulaButton.frame.size.height + 30, fieldWidth, 50);
        } else if(IS_IPHONE_4_OR_LESS) {
            signupButtonRect = CGRectMake((self.view.frame.size.width - fieldWidth)/2, self.view.frame.size.height - 124, fieldWidth, 50);
        }
        
        signupButton = [[SimpleButton alloc] initWithFrame:signupButtonRect
                                                 withTitle:NSLocalizedString(@"NewSignUpButtonTitle", @"")
                                            withTitleColor:[UIColor whiteColor]
                                             withTitleFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:16]
                                           withBorderColor:[UIColor clearColor]
                                               withBgColor:[UIColor whiteColor]
                                          withCornerRadius:0];
        [signupButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
        [signupButton addTarget:self action:@selector(signupClicked) forControlEvents:UIControlEventTouchUpInside];
        signupButton.isAccessibilityElement = YES;
        signupButton.accessibilityIdentifier = @"submitButtonSignUp";
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

- (void)goCountryCodepage:(id)sender {
    _countrySelectionController = [[CountrySelectionController alloc] init];
    self.countrySelectionController.selectedCountry = self.selectedCountry;
    __weak UIButton *weakCountryButton = _countryCodeButton;
    __weak SignupController *weakSelf = self;
    
    _countrySelectionController.completion = ^(NSDictionary *selectedCountry) {
        NSLog(@"selected country = %@", selectedCountry);
        weakSelf.selectedCountry = selectedCountry[@"country_code"];
        [weakCountryButton setTitle:selectedCountry[@"phone_code"] forState:UIControlStateNormal];
    };
    
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:_countrySelectionController];
    [self presentViewController:nav animated:YES completion:nil];
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
    
    [self.view endEditing:YES];
    
//    NSString *trimmedString = [[msisdnField.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    msisdnValue = [NSString stringWithFormat:@"%@%@", _countryCodeButton.titleLabel.text, msisdnField.text];
    
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
    
    APPDELEGATE.session.signupReferenceMsisdn = msisdnValue;
    APPDELEGATE.session.signupReferenceEmail = emailField.text;
    APPDELEGATE.session.signupReferencePassword = passwordField.text;
    
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
    
    [signupDao requestTriggerSignupForEmail:emailField.text forPhoneNumber:msisdnValue withPassword:passwordField.text withEulaId:eula ? eula.eulaId : 0];
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 24, 24) withImageName:@"icon_ustbar_back.png"];
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
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
    [self setViewMovedUp:NO];
}

-(void)setViewMovedUp:(BOOL)movedUp {
    if (movedUp) {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 290);
        if ([passwordField isFirstResponder] || [passwordRepeatField isFirstResponder]) {
            [container setContentOffset:CGPointMake(0,  225) animated:YES];
        } else {
            [container setContentOffset:CGPointMake(0,  112) animated:YES];
        }
    }
    else {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        [container setContentOffset:CGPointZero animated:YES];
    }
}

- (void) msisdnFieldDidChange:(UITextField *) textField {
//    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
//    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
//    NSString* callingCode = @"+(90)";
//    if (isNumeric && [textField.text rangeOfString:@"+"].location == NSNotFound) {
//        if([[Util readLocaleCode] isEqualToString:@"uk"] || [[Util readLocaleCode] isEqualToString:@"ru"] ) {
//            callingCode = @"+(380)";
//            callingCode = [callingCode stringByAppendingString:textField.text];
//            msisdnField.text = callingCode;
//        }
//        else {
//            callingCode = [callingCode stringByAppendingString:textField.text];
//            msisdnField.text = callingCode;
//        }
//    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if([textField isEqual:msisdnField]) {
        if([_countryCodeButton.titleLabel.text isEqualToString:@"+90"]) {
            if ([msisdnField.text hasPrefix:@"0"] && [msisdnField.text length] > 1) {
                msisdnField.text = [msisdnField.text substringFromIndex:1];
            }
        }
    }
    
//    if([textField isEqual:msisdnField]) {
//        if([[Util readLocaleCode] isEqualToString:@"tr"] || [[Util readLocaleCode] isEqualToString:@"en"]) {
//            NSRange range = [textField.text rangeOfString:@")" options:NSBackwardsSearch];
//            if (range.location != NSNotFound) {
//                NSString *callingCode = [textField.text substringToIndex:range.location + 1];
//                if([callingCode isEqualToString:@"+(90)"]) {
//                    NSString *number = [textField.text substringFromIndex:range.location + range.length];
//                    if ([number hasPrefix:@"0"] && [number length] > 1) {
//                        number = [number substringFromIndex:1];
//                        NSString *editedNumber = [callingCode stringByAppendingString:number];
//                        textField.text = editedNumber;
//                    }
//                }
//            }
//        }
//    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
//    [msisdnField resignFirstResponder];
//    [emailField resignFirstResponder];
//    [passwordField resignFirstResponder];
//    [passwordRepeatField resignFirstResponder];
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

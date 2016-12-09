//
//  LoginController.m
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "LoginController.h"
#import "CustomLabel.h"
#import "Util.h"
#import "SimpleButton.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "User.h"
#import "SmsForPassButton.h"
#import "MyMessageComposeViewController.h"
#import "CacheUtil.h"
#import "CurioSDK.h"
#import <SplunkMint/SplunkMint.h>
#import "SignupController.h"
#import "RememberMeEmailViewController.h"
#import "MPush.h"
#import "AppUtil.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface LoginController () {
    UIScrollView* container;
}

@end

@implementation LoginController

@synthesize mainScroll;
@synthesize loginButton;
@synthesize refreshButton;
@synthesize captchaView;
@synthesize msisdnField;
@synthesize passField;
@synthesize captchaField;
@synthesize forgotPassView;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SignIn", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;

        tokenDao = [[RequestTokenDao alloc] init];
        tokenDao.delegate = self;
        tokenDao.successMethod = @selector(tokenDaoSuccessCallback);
        tokenDao.failMethod = @selector(tokenDaoFailCallback:);
        
        captchaDao = [[RequestCaptchaDao alloc] init];
        captchaDao.delegate = self;
        captchaDao.successMethod = @selector(captchaSuccessCallback:);
        captchaDao.failMethod = @selector(captchaFailCallback:);
        
        container = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:container];

        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        mainScroll.scrollEnabled = YES;
        //[self.view addSubview:mainScroll];
        
        int scrollYIndex = 20;
        
        UIImage *logoImage = [UIImage imageNamed:@"icon_lifebox.png"];
        UIImageView *logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoImage.size.width)/2, scrollYIndex, logoImage.size.width, logoImage.size.height)];
        logoImgView.image = logoImage;
//        [mainScroll addSubview:logoImgView];
        [container addSubview:logoImgView];
        
        scrollYIndex += logoImage.size.height+50;
        
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnEmailTitle", @"")];
//        [mainScroll addSubview:msisdnLabel];
        [container addSubview:msisdnLabel];
        
        scrollYIndex += 5;
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 43) withPlaceholder:@""/*NSLocalizedString(@"MsisdnEmailPlaceholder", @"")*/];
        msisdnField.delegate = self;
        [msisdnField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [mainScroll addSubview:msisdnField];
        [container addSubview:msisdnField];
//        if([[Util readLocaleCode] isEqualToString:@"tr"]) {
//            msisdnField.placeholder = @"5XX XXX XX XX";
//        }

        scrollYIndex += 55;

        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
//        [mainScroll addSubview:passLabel];
        [container addSubview:passLabel];
        
        scrollYIndex += 5;

        passField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 43) withPlaceholder:/*NSLocalizedString(@"PasswordPlaceholder", @"")*/ @""];
        passField.delegate = self;
//        [mainScroll addSubview:passField];
        [container addSubview:passField];

        scrollYIndex += 65;

        rememberMe = [[CheckButton alloc] initWithFrame:CGRectMake(25, scrollYIndex, 120, 25) withTitle:NSLocalizedString(@"RememberMe", @"") isInitiallyChecked:YES];
//        [mainScroll addSubview:rememberMe];
        [container addSubview:rememberMe];

//        SimpleButton *forgotPass = [[SimpleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 150, scrollYIndex, 130, 25) withTitle:NSLocalizedString(@"ForgotPassButton", @"")];
//        [forgotPass addTarget:self action:@selector(forgotMeClicked) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:forgotPass];

        scrollYIndex += 40;

        captchaView = [[UIImageView alloc] initWithFrame:CGRectMake(20, scrollYIndex, 200, 50)];
        captchaView.hidden = YES;
//        [mainScroll addSubview:captchaView];
        [container addSubview:captchaView];
        
        refreshButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 38, scrollYIndex, 18, 18) withImageName:@"icon_verif_refresh.png"];
        refreshButton.hidden = YES;
        [refreshButton addTarget:self action:@selector(loadCaptcha) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:refreshButton];
        [container addSubview:refreshButton];
        
        captchaField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, captchaView.frame.origin.y + captchaView.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"CaptchaPlaceholder", @"")];
        captchaField.hidden = YES;
        captchaField.delegate = self;
//        [mainScroll addSubview:captchaField];
        [container addSubview:captchaField];
        
       // scrollYIndex += 20;
        
        loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Login", @"") withTitleColor:[Util UIColorForHexColor:@"FFFFFF"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3FB0E8"] withBgColor:[Util UIColorForHexColor:@"3FB0E8"] withCornerRadius:5];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:loginButton];
        [container addSubview:loginButton];
        
        scrollYIndex += 60;
        
        forgotPassView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 130)/2, scrollYIndex + loginButton.frame.size.height, 130, 25) ];
        [container addSubview:forgotPassView];
        
        UIImage *newPassIcon = [UIImage imageNamed:@"icon_newpass.png"];
        UIImageView *passIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake( 5, 0, newPassIcon.size.width, newPassIcon.size.height)];
        passIconImgView.image = newPassIcon;
//        [mainScroll addSubview:passIconImgView];
        [forgotPassView addSubview:passIconImgView];
        
        SimpleButton *forgotPass = [[SimpleButton alloc] initWithFrame:CGRectMake(0, 0, 130, 25) withTitle:NSLocalizedString(@"ForgotPassButton", @"")];
        [forgotPass addTarget:self action:@selector(forgotMeClicked) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:forgotPass];
        [forgotPassView addSubview:forgotPass];

       // CGRect loginButtonFrame = CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 50);
        
        if(IS_IPAD) {
            msisdnLabel.frame = CGRectMake((self.view.frame.size.width - 320)/2 + 5, (self.view.frame.size.height - 300)/2 - 100, 320, 20);
            msisdnField.frame = CGRectMake((self.view.frame.size.width - 320)/2, msisdnLabel.frame.origin.y + msisdnLabel.frame.size.height + 10, 320, 43);
            passLabel.frame = CGRectMake((self.view.frame.size.width - 320)/2 + 5, msisdnField.frame.origin.y + msisdnField.frame.size.height + 20, 320, 20);
            passField.frame = CGRectMake((self.view.frame.size.width - 320)/2, passLabel.frame.origin.y + passLabel.frame.size.height + 10, 320, 43);
            rememberMe.frame = CGRectMake((self.view.frame.size.width - 320)/2 + 5, passField.frame.origin.y + passField.frame.size.height + 30, 120, 25);
            forgotPass.frame = CGRectMake(passField.frame.origin.x + passField.frame.size.width - 130, rememberMe.frame.origin.y, 130, 25);
            loginButton.frame = CGRectMake((self.view.frame.size.width - 320)/2, rememberMe.frame.origin.y + rememberMe.frame.size.height + 30, 320, 50);
        }
        
//        loginButton = [[SimpleButton alloc] initWithFrame:loginButtonFrame withTitle:NSLocalizedString(@"Login", @"") withTitleColor:[Util UIColorForHexColor:@"FFFFFF"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3FB0E8"] withBgColor:[Util UIColorForHexColor:@"3FB0E8"] withCornerRadius:5];
//        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:loginButton];
//
//        scrollYIndex += 60;
        
        /*
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SmsForPassButton *smsButton = [[SmsForPassButton alloc] initWithFrame:CGRectMake(20, loginButton.frame.origin.y + loginButton.frame.size.height + 10, 280, 40)];
            [smsButton addTarget:self action:@selector(triggerSms) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:smsButton];
            
        }
         */

        SimpleButton *registerButton = [[SimpleButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60) withTitle:NSLocalizedString(@"SignUpButtonTitle", @"") withTitleColor:[UIColor whiteColor] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3FB0E8"] withBgColor:[Util UIColorForHexColor:@"3FB0E8"] withCornerRadius:0];
        [registerButton addTarget:self action:@selector(registerClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registerButton];
        
        mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, scrollYIndex + 120);

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

- (void) forgotMeClicked {
    RememberMeEmailViewController *rememberMeController = [[RememberMeEmailViewController alloc] init];
    [self.navigationController pushViewController:rememberMeController animated:YES];
}

- (void) loadCaptcha {
    captchaUniqueId = [[NSUUID UUID] UUIDString];
    [captchaDao requestCaptchaForType:@"IMAGE" andId:captchaUniqueId];
    captchaField.text = @"";
}

- (void) registerClicked {
    [[CurioSDK shared] sendEvent:@"SignUp" eventValue:@"Start"];
    [MPush hitTag:@"SignUp" withValue:@"Start"];

    SignupController *signup = [[SignupController alloc] init];
    [self.navigationController pushViewController:signup animated:YES];
}

- (void) tokenDaoSuccessCallback {
    [self hideLoading];
    
    if(msisdnValue != nil) {
        [CacheUtil writeCachedMsisdnForPostMigration:msisdnValue];
        if(passValue != nil) {
            [CacheUtil writeCachedPassForPostMigration:passValue];
        }
        [[CurioSDK shared] sendCustomId:msisdnValue];
    }
    
    [[CurioSDK shared] sendEvent:@"LoginSuccess" eventValue:@"true"];
    [[CurioSDK shared] sendEvent:@"Login" eventValue:@"Success"];
    [[CurioSDK shared] sendEvent:@"Mnc" eventValue:[AppUtil readCurrentMobileNetworkCode]];

    [APPDELEGATE triggerPostLogin];
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [[CurioSDK shared] sendEvent:@"Login" eventValue:@"Fail"];
    [MPush hitTag:@"Login" withValue:@"Fail"];

    if([errorMessage isEqualToString:CAPTCHA_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaRequiredErrorMessage", @"")];
        [self loadCaptcha];
    } else if([errorMessage isEqualToString:EMAIL_NOT_VERIFIED_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailNotVerifiedError", @"")];
    } else if([errorMessage isEqualToString:LDAP_LOCKED_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LdapLockedError", @"")];
    } else if([errorMessage isEqualToString:SIGNUP_REQUIRED_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"SignUpRequiredError", @"")];
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LoginError", @"")];
        if(![captchaField isHidden]) {
            [self loadCaptcha];
        }
    }
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

//- (void) textFieldDidEndEditing:(UITextField *)textField {
//    [msisdnField resignFirstResponder];
//    [passField resignFirstResponder];
//    [captchaField resignFirstResponder];
//    
//    if(!textField.secureTextEntry) {
//        NSRange range = [textField.text rangeOfString:@")" options:NSBackwardsSearch];
//        if (range.location != NSNotFound) {
//            NSString *callingCode = [textField.text substringToIndex:range.location + 1];
//            if([callingCode isEqualToString:@"+(90)"]) {
//                NSString *number = [textField.text substringFromIndex:range.location + range.length];
//                if ([number hasPrefix:@"0"] && [number length] > 1) {
//                    number = [number substringFromIndex:1];
//                    NSString *editedNumber = [callingCode stringByAppendingString:number];
//                    textField.text = editedNumber;
//                }
//            }
//        }
//    }
//}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [msisdnField resignFirstResponder];
    [passField resignFirstResponder];
    [captchaField resignFirstResponder];
    
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
    [passField resignFirstResponder];
    [captchaField resignFirstResponder];
    return YES;
}

- (void) triggerSms {
    MyMessageComposeViewController *picker = [[MyMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.body = @"SIFRE";
    picker.recipients = [NSArray arrayWithObjects:@"2222", nil];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:YES];
}

- (void) loginClicked {
    
    NSString *trimmedString = [[msisdnField.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    msisdnValue = trimmedString;
    /*
    if ([msisdnValue length] > 0)
        msisdnValue = [[msisdnValue substringToIndex:1] isEqualToString:@"0"] ? [msisdnValue substringFromIndex:1] : msisdnValue;
    */
    passValue = passField.text;
    
    /*
    if([msisdnValue length] != 10) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnFormatErrorMessage", @"")];
        return;
    }
     */

    if([msisdnValue length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnEmailFormatErrorMessage", @"")];
        return;
    }
    
    if([passValue length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PassFormatErrorMessage", @"")];
        return;
    }
    
    if(![captchaField isHidden] && [captchaField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaFieldErrorMessage", @"")];
        return;
    }
    
    [self.view endEditing:YES];

    if(![captchaField isHidden]) {
        [tokenDao requestTokenForMsisdn:msisdnValue andPassword:passValue shouldRememberMe:rememberMe.isChecked withCaptchaId:captchaUniqueId withCaptchaValue:captchaField.text];
    } else {
        [tokenDao requestTokenForMsisdn:msisdnValue andPassword:passValue shouldRememberMe:rememberMe.isChecked];
    }
    [self showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    IGLog(@"LoginController viewDidLoad");

    [MPush hitTag:@"logged_in" withValue:@"0"];
}

- (void) viewDidAppear:(BOOL)animated {
    //[msisdnField becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) captchaSuccessCallback:(UIImage *) captchaImg {
    captchaView.image = captchaImg;
    
    if(captchaView.isHidden) {
        loginButton.frame = CGRectMake(loginButton.frame.origin.x, captchaField.frame.origin.y + captchaField.frame.size.height + 20, loginButton.frame.size.width, loginButton.frame.size.height);
        
        forgotPassView.frame = CGRectMake(forgotPassView.frame.origin.x, loginButton.frame.origin.y + loginButton.frame.size.height + 60 , forgotPassView.frame.size.width, forgotPassView.frame.size.height);
        
//        mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, mainScroll.contentSize.height + 120);
        container.contentSize = CGSizeMake(container.contentSize.width, self.view.frame.size.height + 200);
        captchaView.hidden = NO;
        captchaField.hidden = NO;
        refreshButton.hidden = NO;
    }
}

- (void) captchaFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

-(void)keyboardWillShow {
    if(captchaField.isFirstResponder || passField.isFirstResponder) {
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

//-(void)setViewMovedUp:(BOOL)movedUp {
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
//}

-(void)setViewMovedUp:(BOOL)movedUp {
    if (movedUp) {
        if(captchaView.isHidden) {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 280);
        }
        else {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 320);
        }
        [container setContentOffset:CGPointMake(0, 150) animated:YES];
    } else {
        if(captchaView.isHidden) {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
        else {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 200);
        }
        [container setContentOffset:CGPointZero animated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

@end

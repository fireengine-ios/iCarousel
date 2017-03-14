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
#define verticalPadding 40.0f

@interface LoginController () {
    UIScrollView* container;
}

@end

@implementation LoginController

@synthesize loginButton;
//@synthesize refreshButton;
@synthesize captchaView;
@synthesize captchaContainer;
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
        
        int scrollYIndex = 20;
        
        UIImage *logoImage = [UIImage imageNamed:@"icon_lifebox.png"];
        UIImageView *logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoImage.size.width)/2, scrollYIndex, logoImage.size.width, logoImage.size.height)];
        logoImgView.image = logoImage;
        [container addSubview:logoImgView];
        
        if (IS_IPHONE_4_OR_LESS) {
            scrollYIndex += logoImage.size.height + 30;
        } else if (IS_IPHONE_5) {
            scrollYIndex += logoImage.size.height + 50;
        } else {
            scrollYIndex += logoImage.size.height + 80;
        }
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 50) withPlaceholder:NSLocalizedString(@"MsisdnEmailPlaceholderNew", @"")];
        msisdnField.delegate = self;
        [msisdnField addTarget:self action:@selector(msisdnFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        msisdnField.isAccessibilityElement = YES;
        msisdnField.accessibilityIdentifier = @"msisdnFieldLogin";
        [container addSubview:msisdnField];

        scrollYIndex += verticalPadding + 20.0f;
        
        passField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 50) withPlaceholder:NSLocalizedString(@"PasswordPlaceholder", @"")];
        passField.delegate = self;
        passField.isAccessibilityElement = YES;
        passField.accessibilityIdentifier = @"passFieldLogin";
        [container addSubview:passField];

        scrollYIndex += verticalPadding + 25.0f;

        rememberMe = [[CheckButton alloc] initWithFrame:CGRectMake(25, scrollYIndex, 120, 25) withTitle:NSLocalizedString(@"RememberMe", @"") isInitiallyChecked:YES];
        rememberMe.isAccessibilityElement = YES;
        rememberMe.accessibilityIdentifier = @"rememberMe";
        [container addSubview:rememberMe];

//        SimpleButton *forgotPass = [[SimpleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 150, scrollYIndex, 130, 25) withTitle:NSLocalizedString(@"ForgotPassButton", @"")];
//        [forgotPass addTarget:self action:@selector(forgotMeClicked) forControlEvents:UIControlEventTouchUpInside];
//        [mainScroll addSubview:forgotPass];
        
        captchaContainer = [[UIView alloc] initWithFrame:CGRectMake(20, scrollYIndex, 200, 100)];
//        captchaContainer.backgroundColor = [UIColor redColor];
        captchaContainer.hidden = YES;
        captchaContainer.isAccessibilityElement = YES;
        captchaContainer.accessibilityIdentifier = @"loginCaptchaContainer";
        [container addSubview:captchaContainer];

        captchaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        UIImage *image = [UIImage imageNamed:@"bg_captcha.png"];
        CGSize newSize = captchaView.frame.size;
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        captchaView.backgroundColor = [UIColor colorWithPatternImage:newImage];
        captchaView.isAccessibilityElement = YES;
        captchaView.accessibilityIdentifier = @"loginCaptchaView";
        [captchaContainer addSubview:captchaView];
        
        CustomButton* refreshButton = [[CustomButton alloc] initWithFrame:CGRectMake(captchaView.frame.origin.x + captchaView.frame.size.width + 32, captchaView.frame.origin.y + (captchaView.frame.size.height - 18)/2, 18, 18) withImageName:@"icon_captcha_refresh.png"];
        [refreshButton addTarget:self action:@selector(loadCaptcha) forControlEvents:UIControlEventTouchUpInside];
        refreshButton.isAccessibilityElement = YES;
        refreshButton.accessibilityIdentifier = @"loginCaptcharefreshButton";
        [captchaContainer addSubview:refreshButton];
        
        captchaField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(0, captchaView.frame.origin.y + captchaView.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"CaptchaPlaceholder", @"")];
        captchaField.delegate = self;
        captchaField.isAccessibilityElement = YES;
        captchaField.accessibilityIdentifier = @"loginCaptchaField";
        [captchaContainer addSubview:captchaField];
        
        scrollYIndex += verticalPadding;
        
        loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, scrollYIndex, self.view.frame.size.width - 40, 50)
                                                withTitle:[NSLocalizedString(@"Login", @"") uppercaseString]
                                           withTitleColor:[Util UIColorForHexColor:@"FFFFFF"]
                                            withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18]
                                          withBorderColor:[Util UIColorForHexColor:@"3FB0E8"]
                                              withBgColor:[Util UIColorForHexColor:@"3FB0E8"]
                                         withCornerRadius:2];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        loginButton.isAccessibilityElement = YES;
        loginButton.accessibilityIdentifier = @"loginButton";
        [container addSubview:loginButton];
        
        if (IS_IPHONE_5) {
            scrollYIndex += loginButton.frame.size.height + 30.0f;
        } else {
            scrollYIndex += loginButton.frame.size.height + 40.0f;
        }
        
        forgotPassView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 130)/2,
                                                                  scrollYIndex,
                                                                  130,
                                                                  25) ];
        forgotPassView.isAccessibilityElement = YES;
        forgotPassView.accessibilityIdentifier = @"forgotPassView";
        [container addSubview:forgotPassView];
        
        UIImage *newPassIcon = [UIImage imageNamed:@"icon_newpass.png"];
        UIImageView *passIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, newPassIcon.size.width, newPassIcon.size.height)];
        passIconImgView.image = newPassIcon;
        [forgotPassView addSubview:passIconImgView];
        
        SimpleButton *forgotPass = [[SimpleButton alloc] initWithFrame:CGRectMake(newPassIcon.size.width + 5, 4, 130, 25) withTitle:NSLocalizedString(@"ForgotPassButton", @"") withTextAlignment:NSTextAlignmentLeft];
        [forgotPass addTarget:self action:@selector(forgotMeClicked) forControlEvents:UIControlEventTouchUpInside];
        forgotPass.isAccessibilityElement = YES;
        forgotPass.accessibilityIdentifier = @"forgotPassButton";
        [forgotPassView addSubview:forgotPass];

        
        if(IS_IPAD) {
            CGRect logoFrame = logoImgView.frame;
            logoFrame.origin.y = 200;
            logoImgView.frame = logoFrame;
            
            
            
            NSMutableArray *viewArray = [@[] mutableCopy];
            
            msisdnField.frame = CGRectMake(0,//(self.view.frame.size.width - 320)/2,
                                           (self.view.frame.size.height - 300)/2 - 100,
                                           480,
                                           msisdnField.frame.size.height);
            [viewArray addObject:msisdnField];
            
            passField.frame = CGRectMake(0,//(self.view.frame.size.width - 320)/2,
                                         msisdnField.frame.origin.y + msisdnField.frame.size.height + 20,
                                         480,
                                         passField.frame.size.height);
            [viewArray addObject:passField];
            
            rememberMe.frame = CGRectMake(0,//(self.view.frame.size.width - 320)/2 + 5,
                                          passField.frame.origin.y + passField.frame.size.height + 30,
                                          480,
                                          rememberMe.frame.size.height);
            [viewArray addObject:rememberMe];
            
            //workaround
            [loginButton removeFromSuperview];
            loginButton = [[SimpleButton alloc] initWithFrame:
                           CGRectMake(0,//(self.view.frame.size.width - 320)/2,
                                      rememberMe.frame.origin.y + rememberMe.frame.size.height + 30,
                                      480,
                                      loginButton.frame.size.height)
                                                    withTitle:NSLocalizedString(@"Login", @"")
                                               withTitleColor:[Util UIColorForHexColor:@"FFFFFF"]
                                                withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18]
                                              withBorderColor:[Util UIColorForHexColor:@"3FB0E8"]
                                                  withBgColor:[Util UIColorForHexColor:@"3FB0E8"]
                                             withCornerRadius:5];
            [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
            loginButton.isAccessibilityElement = YES;
            loginButton.accessibilityIdentifier = @"loginButtonForPAD";
            [container addSubview:loginButton];
            
            [viewArray addObject:loginButton];
            //workaround
            
            forgotPassView.frame = CGRectMake(0,//(self.view.frame.size.width - forgotPassView.frame.size.width)/2 ,
                                              loginButton.frame.origin.y + loginButton.frame.size.height + 30,
                                              forgotPassView.frame.size.width,
                                              forgotPassView.frame.size.height);
            [viewArray addObject:forgotPassView];
            
            captchaContainer.frame = CGRectMake(0,//(self.view.frame.size.width - 320)/2,
                                                rememberMe.frame.origin.y + rememberMe.frame.size.height + 30,
                                                480,
                                                captchaContainer.frame.size.height);
            [viewArray addObject:captchaContainer];
            
            captchaField.frame = CGRectMake(0,//captchaField.frame.origin.x,
                                            captchaField.frame.origin.y,
                                            480,
                                            captchaField.frame.size.height);
            [viewArray addObject:captchaField];
            
            
            for (UIView *view in viewArray) {
                CGPoint center = view.center;
                center.x = self.view.center.x;
                view.center = center;
            }
        }
        
        CGFloat btnWidth = 180.0f, btnHeight = 40.0f;
        CGRect registerButtonFrame = CGRectMake((self.view.frame.size.width - btnWidth) /2,
                                                self.view.frame.size.height - (btnHeight * 2) - 64,
                                                btnWidth,
                                                btnHeight);
        SimpleButton *registerButton = [[SimpleButton alloc] initWithFrame:registerButtonFrame
                                                                 withTitle:[NSLocalizedString(@"SignUpButtonTitle", @"") uppercaseString]
                                                            withTitleColor:[UIColor blackColor]
                                                             withTitleFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:16]
                                                           withBorderColor:[UIColor clearColor]
                                                               withBgColor:[UIColor whiteColor]
                                                          withCornerRadius:2];
        
        [registerButton setBackgroundImage:[UIImage imageNamed:@"buttonbg_720_w"] forState:UIControlStateNormal];

        [registerButton addTarget:self action:@selector(registerClicked) forControlEvents:UIControlEventTouchUpInside];
        registerButton.isAccessibilityElement = YES;
        registerButton.accessibilityIdentifier = @"registerButton";
        [container addSubview:registerButton];
        
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
        [self showErrorAlertWithMessage:NSLocalizedString(@"SignUpRequiredError", @"") withDelegate:self];
    } else if ([errorMessage isEqualToString:NO_CONN_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LoginError", @"")];
        if(![captchaContainer isHidden]) {
            [self loadCaptcha];
        }
    }
}

- (void) didDismissCustomAlert:(CustomAlertView *) alertView {
    SignupController *signup = [[SignupController alloc] init];
    [self.navigationController pushViewController:signup animated:YES];
}

- (void) msisdnFieldDidChange:(UITextField *) textField {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    NSString* callingCode = @"+(90)";
    if (isNumeric && [textField.text rangeOfString:@"+"].location == NSNotFound) {
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
    
    if([textField isEqual:msisdnField]) {
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
    [textField resignFirstResponder];
//    [msisdnField resignFirstResponder];
//    [passField resignFirstResponder];
//    [captchaField resignFirstResponder];
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
    
    [self.view endEditing:YES];
    
    msisdnValue = [[msisdnField.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
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
    
    if(![captchaContainer isHidden] && [captchaField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaFieldErrorMessage", @"")];
        return;
    }

    if(![captchaContainer isHidden]) {
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
    
    if(captchaContainer.isHidden) {
        loginButton.frame = CGRectMake(loginButton.frame.origin.x, captchaContainer.frame.origin.y + captchaContainer.frame.size.height + 20, loginButton.frame.size.width, loginButton.frame.size.height);
        
        forgotPassView.frame = CGRectMake(forgotPassView.frame.origin.x, loginButton.frame.origin.y + loginButton.frame.size.height + 60 , forgotPassView.frame.size.width, forgotPassView.frame.size.height);
        
        if(!IS_IPAD) {
            container.contentSize = CGSizeMake(container.contentSize.width, self.view.frame.size.height);
        }
        captchaContainer.hidden = NO;
    }
}

- (void) captchaFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

-(void)keyboardWillShow {
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
    [self setViewMovedUp:NO];
}

-(void)setViewMovedUp:(BOOL)movedUp {
    if (movedUp) {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 280);
        if(captchaContainer.isHidden) {
            [container setContentOffset:CGPointMake(0, 85) animated:YES];
        }
        else {
            [container setContentOffset:CGPointMake(0, 75) animated:YES];
        }
    } else {
        if(captchaContainer.isHidden) {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
        else {
            container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
        [container setContentOffset:CGPointZero animated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

@end

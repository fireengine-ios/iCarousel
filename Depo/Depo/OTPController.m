//
//  OTPController.m
//  Depo
//
//  Created by Mahir on 08/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "OTPController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "SingleCharField.h"
#import "EmailValidationResultController.h"
#import "EmailValidationController.h"
#import "CurioSDK.h"
#import "AppUtil.h"
#import "MPush.h"

@interface OTPController ()

@end

@implementation OTPController

@synthesize tickTimer;

- (id) initWithRemainingTimeInMinutes:(int) remainingMinutes andInputLength:(int) inputLength withType:(MsisdnUpdateType) _type {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        type = _type;

        if(type == MsisdnUpdateTypeSignup) {
            self.title = NSLocalizedString(@"SignUp", @"");
        } else {
            self.title = NSLocalizedString(@"ChangePhoneTitle", @"");
        }

        self.navigationItem.leftBarButtonItem = nil;
        
        otpLength = inputLength;
        
        verifyDao = [[VerifyPhoneDao alloc] init];
        verifyDao.delegate = self;
        verifyDao.successMethod = @selector(verifySuccessCallback:);
        verifyDao.failMethod = @selector(verifyFailCallback:);
        
        smsDao = [[SendVerificationSMSDao alloc] init];
        smsDao.delegate = self;
        smsDao.successMethod = @selector(smsSuccessCallback:);
        smsDao.failMethod = @selector(smsFailCallback:);
        
        userInfoDao = [[AccountInfoDao alloc] init];
        userInfoDao.delegate = self;
        userInfoDao.successMethod = @selector(userInfoSuccessCallback:);
        userInfoDao.failMethod = @selector(userInfoFailCallback:);

        if(type != MsisdnUpdateTypeSettings) {
            tokenDao = [[RequestTokenDao alloc] init];
            tokenDao.delegate = self;
            tokenDao.successMethod = @selector(tokenDaoSuccessCallback);
            tokenDao.failMethod = @selector(tokenDaoFailCallback:);
        }

        CustomLabel *topInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"OTPTopInfo", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:topInfoLabel];
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topInfoLabel.frame.origin.y + topInfoLabel.frame.size.height + 20, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:22] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:APPDELEGATE.session.signupReferenceMsisdn withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:msisdnLabel];

        CustomLabel *subMsisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, msisdnLabel.frame.origin.y + msisdnLabel.frame.size.height + 5, self.view.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:14] withColor:[Util UIColorForHexColor:@"2E2E2E"] withText:NSLocalizedString(@"OTPSubInfo", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:subMsisdnLabel];
        
        float containerWidth = 280;
        float containerLeftMargin = (self.view.frame.size.width - 280)/2;
        float marginBetween = (containerWidth - (inputLength*40))/(inputLength-1);
        
        for(int i=0; i<inputLength; i++) {
            SingleCharField *charField = [[SingleCharField alloc] initWithFrame:CGRectMake(containerLeftMargin + i*(40+marginBetween), subMsisdnLabel.frame.origin.y + subMsisdnLabel.frame.size.height + 20, 40, 40)];
            charField.delegate = self;
            charField.backDelegate = self;
            charField.tag = 100 + i;
            charField.keyboardType = UIKeyboardTypeNumberPad;
            [self.view addSubview:charField];
        }
        
        remainingTimeInSec = remainingMinutes * 60;
        
        counterLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, subMsisdnLabel.frame.origin.y + subMsisdnLabel.frame.size.height + 80, self.view.frame.size.width, 100) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:100] withColor:[Util UIColorForHexColor:@"33B1E3"] withText:[self timeFormatted:remainingTimeInSec] withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:counterLabel];
        
        resendButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, counterLabel.frame.origin.y + counterLabel.frame.size.height + 20, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"ResendButton", @"") withTitleColor:[Util UIColorForHexColor:@"3E3E3E"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3E3E3E"] withBgColor:[Util UIColorForHexColor:@"FFFFFF"] withCornerRadius:3];
        resendButton.hidden = YES;
        [resendButton addTarget:self action:@selector(resendCode) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resendButton];
        
        tickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target: self selector: @selector(tickForSecond) userInfo: nil repeats: YES];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
    }
    return self;
}

- (void) triggerResign {
    [self.view endEditing:YES];
}

- (void) resendCode {
    [[CurioSDK shared] sendEvent:@"SignUp>Otp" eventValue:@"Resend"];
    [MPush hitTag:@"Signup>Otp" withValue:@"Resend"];
    
    [smsDao requestTriggerSendVerificationSMS:APPDELEGATE.session.otpReferenceToken];
    [self showLoading];
}

- (void) verifySuccessCallback:(NSString *) statusVal {
    NSString *curioPreEvent = @"SignUp";
    if(type == MsisdnUpdateTypeSettings) {
        curioPreEvent = @"MsisdnUpdate";
    } else if(type == MsisdnUpdateTypeEmpty) {
        curioPreEvent = @"MsisdnEntry";
    }
    
    if([statusVal isEqualToString:@"CONTINUE_WITH_EMAIL_VERIFICATION"]) {
        [self hideLoading];
        [[CurioSDK shared] sendEvent:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] eventValue:@"Success"];
        [MPush hitTag:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] withValue:@"Success"];

        EmailValidationResultController *emailResultController = [[EmailValidationResultController alloc] initWithEmailVal:APPDELEGATE.session.signupReferenceEmail];
        [self.navigationController pushViewController:emailResultController animated:YES];
    } else if([statusVal isEqualToString:@"EXPIRED_OTP"]) {
        [self hideLoading];
        [[CurioSDK shared] sendEvent:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] eventValue:@"Fail"];
        [MPush hitTag:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] withValue:@"Fail"];

        [self showErrorAlertWithMessage:NSLocalizedString(@"OTPExpired", @"")];
        [self cleanOTPFields];
    } else if([statusVal isEqualToString:@"INVALID_OTP"]) {
        [self hideLoading];
        [[CurioSDK shared] sendEvent:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] eventValue:@"Fail"];
        [MPush hitTag:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] withValue:@"Fail"];

        [self showErrorAlertWithMessage:NSLocalizedString(@"OTPInvalid", @"")];
        [self cleanOTPFields];
    } else if([statusVal isEqualToString:@"INVALID_TOKEN"]) {
        [self hideLoading];
        [self showErrorAlertWithMessage:NSLocalizedString(@"RefCodeInvalid", @"")];
        [self.navigationController popViewControllerAnimated:YES];
    } else if([statusVal isEqualToString:@"TOO_MANY_INVALID_ATTEMPTS"]) {
        [self hideLoading];
        [[CurioSDK shared] sendEvent:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] eventValue:@"Fail"];
        [MPush hitTag:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] withValue:@"Fail"];

        [self showErrorAlertWithMessage:NSLocalizedString(@"TOO_MANY_INVALID_ATTEMPTS", @"")];
        [self cleanOTPFields];
        [self prepareForResend];
    } else if([statusVal isEqualToString:@"OK"]) {
        [[CurioSDK shared] sendEvent:curioPreEvent eventValue:@"Finish"];
        [MPush hitTag:curioPreEvent withValue:@"Finish"];

//        [self showInfoAlertWithMessage:NSLocalizedString(@"SignupSuccess", @"")];
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.view endEditing:YES];
        if(type == MsisdnUpdateTypeSettings) {
            [userInfoDao requestAccountInfo];
        } else if(type == MsisdnUpdateTypeSignup) {
            [tokenDao requestTokenForMsisdn:APPDELEGATE.session.signupReferenceMsisdn andPassword:APPDELEGATE.session.signupReferencePassword shouldRememberMe:YES];
        } else if(type == MsisdnUpdateTypeEmpty) {
            [tokenDao requestTokenForMsisdn:[CacheUtil readCachedMsisdnForPostMigration] andPassword:[CacheUtil readCachedPassForPostMigration] shouldRememberMe:YES];
        }
    } else {
        [self hideLoading];
        [[CurioSDK shared] sendEvent:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] eventValue:@"Fail"];
        [MPush hitTag:[NSString stringWithFormat:@"%@>Otp", curioPreEvent] withValue:@"Fail"];
        [self showErrorAlertWithMessage:NSLocalizedString(statusVal, @"")];
        [self cleanOTPFields];
    }
}

- (void) verifyFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) smsSuccessCallback:(NSDictionary *) resultDict {
    [self hideLoading];

    NSString *resultStatus = [resultDict objectForKey:@"status"];
    if(resultStatus != nil && ![resultStatus isKindOfClass:[NSNull class]]) {
        if([resultStatus isEqualToString:@"INVALID_SIGN_UP_SESSION"]) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"InvalidSignupSession", @"")];
            [self.navigationController popViewControllerAnimated:YES];
        } else if([resultStatus isEqualToString:@"WAITING_FOR_TIMEOUT_PERIOD"]) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"OTPWaitingForTimeoutPeriod", @"")];
        } else if([resultStatus isEqualToString:@"TOO_MANY_REQUESTS"]) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"OTPTooManyRequests", @"")];
        } else if([resultStatus isEqualToString:@"OK"]) {
            for (UIView *subview in [self.view subviews]) {
                if([subview isKindOfClass:[UITextField class]]) {
                    [(UITextField *) subview setText:@""];
                }
            }
            
            NSDictionary *valueDict = [resultDict objectForKey:@"value"];
            if(valueDict != nil && [valueDict isKindOfClass:[NSDictionary class]]) {
                NSString *referenceToken = [valueDict objectForKey:@"referenceToken"];
                NSNumber *remainingTimeInMinutes = [valueDict objectForKey:@"remainingTimeInMinutes"];
                NSNumber *expectedInputLength = [valueDict objectForKey:@"expectedInputLength"];

                if(referenceToken != nil && ![referenceToken isKindOfClass:[NSNull class]]) {
                    APPDELEGATE.session.otpReferenceToken = referenceToken;
                }
                
                otpLength = [expectedInputLength intValue];
                remainingTimeInSec = [remainingTimeInMinutes intValue] * 60;

                if(tickTimer) {
                    [tickTimer invalidate];
                    tickTimer = nil;
                }
                tickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target: self selector: @selector(tickForSecond) userInfo: nil repeats: YES];

                UIView *firstCharField = [self.view viewWithTag:100];
                if(firstCharField != nil && [firstCharField isKindOfClass:[SingleCharField class]]) {
                    SingleCharField *firstCharFieldCast = (SingleCharField *) firstCharField;
                    [firstCharFieldCast becomeFirstResponder];
                }
                
                resendButton.hidden = YES;

            }
        }
    }
}

- (void) smsFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) userInfoSuccessCallback:(User *) enrichedUser {
    APPDELEGATE.session.user = enrichedUser;
    [self hideLoading];
    [self showInfoAlertWithMessage:NSLocalizedString(@"MsisdnUpdateSuccess", @"")];
    [self.navigationController popToRootViewControllerAnimated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MSISDN_CHANGED_NOTIFICATION object:nil userInfo:nil];
}

- (void) userInfoFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    APPDELEGATE.session.user.phoneNumber = [CacheUtil readCachedMsisdnForPostMigration];
    [self showInfoAlertWithMessage:NSLocalizedString(@"MsisdnUpdateSuccess", @"")];
    [self.navigationController popToRootViewControllerAnimated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MSISDN_CHANGED_NOTIFICATION object:nil userInfo:nil];
}

- (BOOL) textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldProcess = NO;
    BOOL shouldMoveToPreviousField = NO;
    BOOL shouldMoveToNextField = NO;
    
    int insertStringLength = (int)[string length];
    if(insertStringLength == 0) {
        shouldProcess = YES;
    } else {
        if([[textField text] length] == 0) {
            shouldProcess = YES;
        }
    }
    if(range.length == 1) {
        shouldMoveToPreviousField = YES;
    }
    
    if(shouldProcess){
        NSMutableString* mstring = [[textField text] mutableCopy];
        if([mstring length] == 0){
            [mstring appendString:string];
            shouldMoveToNextField = YES;
        } else {
            if(insertStringLength > 0){
                [mstring insertString:string atIndex:range.location];
            } else {
                [mstring deleteCharactersInRange:range];
            }
        }
        
        [textField setText:mstring];
        
        if (shouldMoveToNextField) {
            int nextTag = (int)textField.tag + 1;
            UIView *nextView = [self.view viewWithTag:nextTag];
            if(nextView != nil && [nextView isKindOfClass:[SingleCharField class]]) {
                SingleCharField *nextField = (SingleCharField *) nextView;
                nextField.text = @"";
                [nextField becomeFirstResponder];
            } else {
                NSMutableString *otpVal = [[NSMutableString alloc] init];
                for(int i=0; i<otpLength; i++) {
                    UIView *inputView = [self.view viewWithTag:(100+i)];
                    if(inputView != nil && [inputView isKindOfClass:[SingleCharField class]]) {
                        SingleCharField *inputCharField = (SingleCharField *) inputView;
                        [otpVal appendString:inputCharField.text];
                    }
                }
                if(otpVal.length == otpLength) {
                    [self.view endEditing:YES];
                    if(type == MsisdnUpdateTypeSignup) {
                        [verifyDao requestTriggerVerifyPhone:APPDELEGATE.session.otpReferenceToken withOTP:otpVal];
                    } else {
                        [verifyDao requestTriggerVerifyPhoneToUpdate:APPDELEGATE.session.otpReferenceToken withOTP:otpVal];
                    }
                    [self showLoading];
                }
            }
        } else if(shouldMoveToPreviousField) {
            int previousTag = (int)textField.tag - 1;
            UIView *previousView = [self.view viewWithTag:previousTag];
            if(previousView != nil && [previousView isKindOfClass:[SingleCharField class]]) {
                SingleCharField *previousField = (SingleCharField *) previousView;
                [previousField becomeFirstResponder];
            }
        }
    }
    
    //always return no since we are manually changing the text field
    return NO;
}

- (void) cleanOTPFields {
    for(int i=0; i<otpLength; i++) {
        UIView *inputView = [self.view viewWithTag:(100+i)];
        if(inputView != nil && [inputView isKindOfClass:[SingleCharField class]]) {
            SingleCharField *inputCharField = (SingleCharField *) inputView;
            inputCharField.text = @"";
        }
    }
}

- (void) prepareForResend {
    remainingTimeInSec = 0;
    counterLabel.text = [self timeFormatted:remainingTimeInSec];
    if(tickTimer) {
        [tickTimer invalidate];
        tickTimer = nil;
    }
    resendButton.hidden = NO;
    [self.view endEditing:YES];
}

- (void) tickForSecond {
    remainingTimeInSec --;
    if(remainingTimeInSec >= 0) {
        counterLabel.text = [self timeFormatted:remainingTimeInSec];
    } else {
        [self prepareForResend];
    }
}

- (NSString *) timeFormatted:(int) totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"OTPController viewDidLoad");
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(innerTriggerBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;

    UIView *firstCharField = [self.view viewWithTag:100];
    if(firstCharField != nil && [firstCharField isKindOfClass:[SingleCharField class]]) {
        SingleCharField *firstCharFieldCast = (SingleCharField *) firstCharField;
        [firstCharFieldCast becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) emptyBackClickedForField:(int)fieldTag {
    int previousTag = fieldTag - 1;
    UIView *previousView = [self.view viewWithTag:previousTag];
    if(previousView != nil && [previousView isKindOfClass:[SingleCharField class]]) {
        SingleCharField *previousField = (SingleCharField *) previousView;
        [previousField becomeFirstResponder];
    }
}

- (void) innerTriggerBack {
    [[CurioSDK shared] sendEvent:@"SignUp>Otp" eventValue:@"Back"];
    [MPush hitTag:@"SignUp>Otp" withValue:@"Back"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) tokenDaoSuccessCallback {
    [self hideLoading];
    
    [CacheUtil writeCachedMsisdnForPostMigration:APPDELEGATE.session.signupReferenceMsisdn];
    [CacheUtil writeCachedPassForPostMigration:APPDELEGATE.session.signupReferencePassword];
    
    [[CurioSDK shared] sendCustomId:APPDELEGATE.session.signupReferenceMsisdn];
    
    //TODO check hangisi dogru
    [[CurioSDK shared] sendEvent:@"LoginSuccess" eventValue:@"true"];
    [[CurioSDK shared] sendEvent:@"Login" eventValue:@"Success"];
    [MPush hitTag:@"Login" withValue:@"Success"];

    [[CurioSDK shared] sendEvent:@"Mnc" eventValue:[AppUtil readCurrentMobileNetworkCode]];
    [MPush hitTag:@"Mnc" withValue:[AppUtil readCurrentMobileNetworkCode]];

    [APPDELEGATE triggerPostLogin];
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [[CurioSDK shared] sendEvent:@"Login" eventValue:@"Fail"];
    [MPush hitTag:@"Login" withValue:@"Fail"];
    
    if([errorMessage isEqualToString:CAPTCHA_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaRequiredErrorMessage", @"")];
    } else if([errorMessage isEqualToString:EMAIL_NOT_VERIFIED_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailNotVerifiedError", @"")];
    } else if([errorMessage isEqualToString:LDAP_LOCKED_ERROR_MESSAGE]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LdapLockedError", @"")];
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LoginError", @"")];
    }
    [APPDELEGATE triggerLogin];
}

@end

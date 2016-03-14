//
//  OTPController.h
//  Depo
//
//  Created by Mahir on 08/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "VerifyPhoneDao.h"
#import "SendVerificationSMSDao.h"
#import "CustomLabel.h"
#import "SimpleButton.h"
#import "SingleCharField.h"
#import "RequestTokenDao.h"
#import "AccountInfoDao.h"

@interface OTPController : MyViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, SingleCharFieldBackDelegate> {

    VerifyPhoneDao *verifyDao;
    SendVerificationSMSDao *smsDao;
    RequestTokenDao *tokenDao;
    AccountInfoDao *userInfoDao;

    CustomLabel *counterLabel;
    SimpleButton *resendButton;
    
    int remainingTimeInSec;
    int otpLength;
    MsisdnUpdateType type;
}

@property (nonatomic, strong) NSTimer *tickTimer;

- (id) initWithRemainingTimeInMinutes:(int) remainingMinutes andInputLength:(int) inputLength withType:(MsisdnUpdateType) _type;

@end

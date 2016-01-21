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

@interface OTPController : MyViewController <UITextFieldDelegate> {
    VerifyPhoneDao *verifyDao;
    SendVerificationSMSDao *smsDao;

    CustomLabel *counterLabel;
    SimpleButton *resendButton;
    
    int remainingTimeInSec;
    int otpLength;
}

@property (nonatomic, strong) NSTimer *tickTimer;

- (id) initWithRemainingTimeInMinutes:(int) remainingMinutes andInputLength:(int) inputLength;

@end

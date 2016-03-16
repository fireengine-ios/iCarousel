//
//  MsisdnEntryController.m
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MsisdnEntryController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "LoginTextfield.h"
#import "OTPController.h"
#import "AppDelegate.h"

@interface MsisdnEntryController ()

@end

@implementation MsisdnEntryController

@synthesize msisdnField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"MsisdnEntry", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        msisdnDao = [[UpdateMsisdnDao alloc] init];
        msisdnDao.delegate = self;
        msisdnDao.successMethod = @selector(updateMsisdnSuccessCallback:);
        msisdnDao.failMethod = @selector(updateMsisdnFailCallback:);
        
        float containerWidth = 280;
        float containerLeftMargin = (self.view.frame.size.width - containerWidth)/2;

        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(containerLeftMargin + 5, 50, containerWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [self.view addSubview:msisdnLabel];
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(containerLeftMargin, msisdnLabel.frame.origin.y + msisdnLabel.frame.size.height + 15, containerWidth, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        msisdnField.delegate = self;
        msisdnField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:msisdnField];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(containerLeftMargin, msisdnField.frame.origin.y + msisdnField.frame.size.height + 25, containerWidth, 50) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(triggerSave) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:okButton];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [self.view endEditing:YES];
}

- (void) triggerSave {
    if([msisdnField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnFormatErrorMessage", @"")];
        return;
    }
    [self.view endEditing:YES];
    [msisdnDao requestUpdateMsisdn:msisdnField.text];
    [self showLoading];
}

- (void) updateMsisdnSuccessCallback:(NSDictionary *) resultDict {
    [self hideLoading];
    
    NSString *resultStatus = [resultDict objectForKey:@"status"];
    BOOL continueWithOTP = NO;
    
    if([resultStatus isEqualToString:@"PHONE_NUMBER_IS_ALREADY_EXIST"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PHONE_NUMBER_IS_ALREADY_EXIST", @"")];
    } else if([resultStatus isEqualToString:@"CAN_NOT_CHANGE_MSISDN"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CAN_NOT_CHANGE_MSISDN", @"")];
    } else if([resultStatus isEqualToString:@"TOO_MANY_REQUESTS"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"TOO_MANY_REQUESTS", @"")];
    } else if([resultStatus isEqualToString:POST_SIGNUP_ACTION_OTP] ){
        continueWithOTP = YES;
    } else if([resultStatus isEqualToString:@"OK"] ){
        NSDictionary *actionDict = [resultDict objectForKey:@"value"];
        if(actionDict != nil && [actionDict isKindOfClass:[NSDictionary class]]) {
            NSString *action = [actionDict objectForKey:@"action"];
            if(action != nil && [action isKindOfClass:[NSString class]]) {
                if([action isEqualToString:POST_SIGNUP_ACTION_OTP]) {
                    continueWithOTP = YES;
                }
            }
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(resultStatus, @"")];
    }
    
    if(continueWithOTP) {
        NSDictionary *actionDict = [resultDict objectForKey:@"value"];
        NSString *refToken = [actionDict objectForKey:@"referenceToken"];
        NSNumber *remainingTimeInMinutes = [actionDict objectForKey:@"remainingTimeInMinutes"];
        NSNumber *expectedInputLength = [actionDict objectForKey:@"expectedInputLength"];
        APPDELEGATE.session.otpReferenceToken = refToken;
        [CacheUtil writeCachedMsisdnForPostMigration:msisdnField.text];
        
        OTPController *otp = [[OTPController alloc] initWithRemainingTimeInMinutes:[remainingTimeInMinutes intValue] andInputLength:[expectedInputLength intValue] withType:MsisdnUpdateTypeEmpty];
        [self.navigationController pushViewController:otp animated:YES];
    }
}

- (void) updateMsisdnFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [msisdnField resignFirstResponder];
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"CancelButtonTittle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void) triggerDismiss {
    [APPDELEGATE triggerLogout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

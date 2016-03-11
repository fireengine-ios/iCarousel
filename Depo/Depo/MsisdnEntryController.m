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
        
        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 50, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [self.view addSubview:msisdnLabel];
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, msisdnLabel.frame.origin.y + msisdnLabel.frame.size.height + 15, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        msisdnField.delegate = self;
        msisdnField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:msisdnField];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, msisdnField.frame.origin.y + msisdnField.frame.size.height + 25, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
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

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateMsisdnSuccessCallback:(NSDictionary *) resultDict {
    [self hideLoading];
    NSString *resultStatus = [resultDict objectForKey:@"status"];
    if([resultStatus isEqualToString:@"PHONE_NUMBER_IS_ALREADY_EXIST"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PHONE_NUMBER_IS_ALREADY_EXIST", @"")];
    } else if([resultStatus isEqualToString:@"CAN_NOT_CHANGE_MSISDN"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CAN_NOT_CHANGE_MSISDN", @"")];
    } else if([resultStatus isEqualToString:@"TOO_MANY_REQUESTS"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"TOO_MANY_REQUESTS", @"")];
    } else if([resultStatus isEqualToString:@"OK"]){
        //TODO "OK" akışını kontrol et
        NSDictionary *actionDict = [resultDict objectForKey:@"value"];
        if(actionDict != nil && [actionDict isKindOfClass:[NSDictionary class]]) {
            NSString *action = [actionDict objectForKey:@"action"];
            NSString *refToken = [actionDict objectForKey:@"referenceToken"];
            NSNumber *remainingTimeInMinutes = [actionDict objectForKey:@"remainingTimeInMinutes"];
            NSNumber *expectedInputLength = [actionDict objectForKey:@"expectedInputLength"];
            if(action != nil && [action isKindOfClass:[NSString class]]) {
                if([action isEqualToString:POST_SIGNUP_ACTION_OTP]) {
                    APPDELEGATE.session.signupReferenceToken = refToken;
                    
                    OTPController *otp = [[OTPController alloc] initWithRemainingTimeInMinutes:[remainingTimeInMinutes intValue] andInputLength:[expectedInputLength intValue]];
                    [self.navigationController pushViewController:otp animated:YES];
                }
            }
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(resultStatus, @"")];
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

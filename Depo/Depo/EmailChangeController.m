//
//  EmailChangeController.m
//  Depo
//
//  Created by Mahir Tarlan on 23/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EmailChangeController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "MPush.h"

@interface EmailChangeController ()

@end

@implementation EmailChangeController

@synthesize emailField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"EmailUpdate", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        emailDao = [[UpdateEmailDao alloc] init];
        emailDao.delegate = self;
        emailDao.successMethod = @selector(updateEmailSuccessCallback:);
        emailDao.failMethod = @selector(updateEmailFailCallback:);
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 50, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];
        
        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"EmailPlaceholder", @"")];
        emailField.delegate = self;
        if(APPDELEGATE.session.user.email != nil) {
            emailField.placeholder = APPDELEGATE.session.user.email;
        }
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailField.isAccessibilityElement = YES;
        emailField.accessibilityIdentifier = @"emailFieldEmailChange";
        [self.view addSubview:emailField];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, emailField.frame.origin.y + emailField.frame.size.height + 10, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(triggerSave) forControlEvents:UIControlEventTouchUpInside];
        okButton.isAccessibilityElement = YES;
        okButton.accessibilityIdentifier = @"okButtonEmailChange";
        [self.view addSubview:okButton];
        
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

- (void) triggerSave {
    if([emailField.text length] == 0 || ![Util isValidEmail:emailField.text]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailFormatErrorMessage", @"")];
        return;
    }
    [self.view endEditing:YES];
    
    NSString *confirmMessage = [NSString stringWithFormat:NSLocalizedString(@"EmailUpdateConfirmMessage", @""), emailField.text];
    CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"EmailConfirmUpdate", @"") withApproveTitle:NSLocalizedString(@"EmailConfirmContinue", @"") withMessage:confirmMessage withModalType:ModalTypeApprove];
    confirm.delegate = self;
    [APPDELEGATE showCustomConfirm:confirm];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
    [emailDao requestUpdateEmail:emailField.text];
    [self showLoading];
}


- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CurioSDK shared] sendEvent:@"EmailEntry" eventValue:@"opened"];
    [MPush hitTag:@"EmailEntry" withValue:@"opened"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateEmailSuccessCallback:(NSString *) resultStatus {
    [self hideLoading];
    if([resultStatus isEqualToString:@"EMAIL_ALREADY_EXISTS"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailAlreadyExist", @"")];
    } else if([resultStatus isEqualToString:@"EMAIL_IS_INVALID"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailInvalid", @"")];
    } else if([resultStatus isEqualToString:@"CAN_NOT_CHANGE_EMAIL"]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CannotChangeEmail", @"")];
    } else {
        [[CurioSDK shared] sendEvent:@"EmailEntry" eventValue:@"finished"];
        [MPush hitTag:@"EmailEntry" withValue:@"finished"];
        APPDELEGATE.session.user.email = emailField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_CHANGED_NOTIFICATION object:nil userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) updateEmailFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [emailField resignFirstResponder];
    return YES;
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

@end

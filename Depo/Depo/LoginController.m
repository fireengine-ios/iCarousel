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

@interface LoginController ()

@end

@implementation LoginController

@synthesize msisdnField;
@synthesize passField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SignIn", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;

        tokenDao = [[RequestTokenDao alloc] init];
        tokenDao.delegate = self;
        tokenDao.successMethod = @selector(tokenDaoSuccessCallback);
        tokenDao.failMethod = @selector(tokenDaoFailCallback:);

        CustomLabel *msisdnLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 50, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"MsisdnTitle", @"")];
        [self.view addSubview:msisdnLabel];
        
        msisdnField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, 75, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        msisdnField.delegate = self;
        msisdnField.placeholder = @"5xxxxxxxxx";
        [self.view addSubview:msisdnField];

        CustomLabel *passLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 130, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"PasswordTitle", @"")];
        [self.view addSubview:passLabel];
        
        passField = [[LoginTextfield alloc] initSecureWithFrame:CGRectMake(20, 155, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"PasswordPlaceholder", @"")];
        passField.delegate = self;
        [self.view addSubview:passField];

        rememberMe = [[CheckButton alloc] initWithFrame:CGRectMake(25, 220, 120, 25) withTitle:NSLocalizedString(@"RememberMe", @"") isInitiallyChecked:YES];
        [self.view addSubview:rememberMe];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SmsForPassButton *smsButton = [[SmsForPassButton alloc] initWithFrame:CGRectMake(20, 280, 280, 40)];
            [smsButton addTarget:self action:@selector(triggerSms) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:smsButton];
            
        }

        SimpleButton *loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 134, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"SignIn", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
    }
    return self;
}

- (void) tokenDaoSuccessCallback {
    [self hideLoading];
    
    if(msisdnValue != nil) {
        [[CurioSDK shared] sendCustomId:msisdnValue];
        [[Mint sharedInstance] setUserIdentifier:msisdnValue];
    }
    [[CurioSDK shared] sendEvent:@"LoginSuccess" eventValue:@"true"];
    [APPDELEGATE triggerPostLogin];
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:NSLocalizedString(@"LoginError", @"")];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [msisdnField resignFirstResponder];
    [passField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [msisdnField resignFirstResponder];
    [passField resignFirstResponder];
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
    msisdnValue = msisdnField.text;
    if ([msisdnValue length] > 0)
        msisdnValue = [[msisdnValue substringToIndex:1] isEqualToString:@"0"] ? [msisdnValue substringFromIndex:1] : msisdnValue;
    
    passValue = passField.text;
    
    if([msisdnValue length] != 10) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnFormatErrorMessage", @"")];
        return;
    }
    if([passValue length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PassFormatErrorMessage", @"")];
        return;
    }
    
    [tokenDao requestTokenForMsisdn:msisdnValue andPassword:passValue shouldRememberMe:rememberMe.isChecked];
    [self showLoading];
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

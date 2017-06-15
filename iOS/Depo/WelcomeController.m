//
//  WelcomeController.m
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "WelcomeController.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "Util.h"
#import "LoginController.h"
#import "SignupController.h"
#import "CurioSDK.h"
#import "MPush.h"

@interface WelcomeController ()

@end

@implementation WelcomeController

- (id) init {
    if(self = [super init]) {
        UIImage *bgImg = [UIImage imageNamed:@"welcome_bg.png"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        bgImgView.image = bgImg;
        [self.view addSubview:bgImgView];
        
        float topIndex = 100;
        if(IS_IPHONE_5) {
            topIndex = 150;
        }
        
        UIImage *iconImage = [UIImage imageNamed:@"welcome_cloud.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - iconImage.size.width)/2, topIndex, iconImage.size.width, iconImage.size.height)];
        iconView.image = iconImage;
        [self.view addSubview:iconView];
        
        topIndex += iconView.frame.size.height + 20;
        
        CustomLabel *subTitle = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, topIndex, 280, 60) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[UIColor whiteColor] withText:NSLocalizedString(@"WelcomePageSubMessage", @"") withAlignment:NSTextAlignmentCenter numberOfLines:3];
        [self.view addSubview:subTitle];
        
        CGSize buttonSize = CGSizeMake(280, 50);

        CustomButton *signupButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize.width)/2, self.view.frame.size.height - 100, buttonSize.width, buttonSize.height) withImageName:@"buttonbg_blue.png" withTitle:NSLocalizedString(@"SignUp", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor]];
        [signupButton addTarget:self action:@selector(triggerSignup) forControlEvents:UIControlEventTouchUpInside];
        signupButton.isAccessibilityElement = YES;
        signupButton.accessibilityIdentifier = @"signupButtonWelcome";
        [self.view addSubview:signupButton];

        CustomButton *loginButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize.width)/2, self.view.frame.size.height - signupButton.frame.size.height - 110, buttonSize.width, buttonSize.height) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"Login", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [loginButton addTarget:self action:@selector(triggerLogin) forControlEvents:UIControlEventTouchUpInside];
        loginButton.isAccessibilityElement = YES;
        loginButton.accessibilityIdentifier = @"loginButtonWelcome";
        [self.view addSubview:loginButton];
        
        if(IS_IPAD) {
            iconView.frame = CGRectMake(iconView.frame.origin.x, self.view.frame.size.width/2 - 150, iconView.frame.size.width, iconView.frame.size.height);
            subTitle.frame = CGRectMake(subTitle.frame.origin.x, iconView.frame.origin.y + iconView.frame.size.height + 20, subTitle.frame.size.width, subTitle.frame.size.height);
            loginButton.frame = CGRectMake(loginButton.frame.origin.x, (self.view.frame.size.width)/2 + 150, loginButton.frame.size.width, loginButton.frame.size.height);
            signupButton.frame = CGRectMake(signupButton.frame.origin.x, loginButton.frame.origin.y + loginButton.frame.size.height + 20, signupButton.frame.size.width, signupButton.frame.size.height);
        }
    }
    return self;
}

- (void) triggerLogin {
    [[CurioSDK shared] sendEvent:@"Welcome" eventValue:@"login_clicked"];
    [MPush hitTag:@"Welcome" withValue:@"login_clicked"];
    LoginController *login = [[LoginController alloc] init];
    [self.navigationController pushViewController:login animated:YES];
}

- (void) triggerSignup {
    [[CurioSDK shared] sendEvent:@"Welcome" eventValue:@"signup_clicked"];
    [MPush hitTag:@"Welcome" withValue:@"signup_clicked"];
    SignupController *signup = [[SignupController alloc] init];
    [self.navigationController pushViewController:signup animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"WelcomeController at viewDidLoad");
    [[CurioSDK shared] sendEvent:@"Welcome" eventValue:@"shown"];
    [MPush hitTag:@"Welcome" withValue:@"shown"];
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

@end

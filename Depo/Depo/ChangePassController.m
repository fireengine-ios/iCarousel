//
//  ChangePassController.m
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ChangePassController.h"
#import "Util.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface ChangePassController ()

@end

@implementation ChangePassController

@synthesize updatedPassField;
@synthesize updatedPassAgainField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"PasswordChangeTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 30, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        emailLabel.isAccessibilityElement = YES;
        emailLabel.accessibilityIdentifier = @"emailLabelChangePass";
        [self.view addSubview:emailLabel];
        
        LoginTextfield *emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:@""];
        emailField.text = APPDELEGATE.session.user.email;
        [emailField setUserInteractionEnabled:NO];
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailField.isAccessibilityElement = YES;
        emailField.accessibilityIdentifier = @"emailFieldChangePass";
        [self.view addSubview:emailField];

        CustomLabel *newPassLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, emailField.frame.origin.y + emailField.frame.size.height + 20, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"NewPass", @"")];
        newPassLabel.isAccessibilityElement = YES;
        newPassLabel.accessibilityIdentifier = @"newPassLabelChangePass";
        [self.view addSubview:newPassLabel];
        
        updatedPassField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, newPassLabel.frame.origin.y + newPassLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:@""];
        updatedPassField.delegate = self;
        updatedPassField.secureTextEntry = YES;
        updatedPassField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        updatedPassField.isAccessibilityElement = YES;
        updatedPassField.accessibilityIdentifier = @"updatedPassFieldChangePass";
        [self.view addSubview:updatedPassField];

        CustomLabel *newPassLabelAgain = [[CustomLabel alloc] initWithFrame:CGRectMake(25, updatedPassField.frame.origin.y + updatedPassField.frame.size.height + 20, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"NewPassAgain", @"")];
        newPassLabelAgain.isAccessibilityElement = YES;
        newPassLabelAgain.accessibilityIdentifier = @"newPassAgainChangePass";
        [self.view addSubview:newPassLabelAgain];
        
        updatedPassAgainField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, newPassLabelAgain.frame.origin.y + newPassLabelAgain.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:@""];
        updatedPassAgainField.delegate = self;
        updatedPassAgainField.secureTextEntry = YES;
        updatedPassAgainField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        updatedPassAgainField.isAccessibilityElement = YES;
        updatedPassAgainField.accessibilityIdentifier = @"updatedPassAgainChangePass";
        [self.view addSubview:updatedPassAgainField];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, updatedPassAgainField.frame.origin.y + updatedPassAgainField.frame.size.height + 30, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"ChangePassButton", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [okButton addTarget:self action:@selector(triggerSave) forControlEvents:UIControlEventTouchUpInside];
        okButton.isAccessibilityElement = YES;
        okButton.accessibilityIdentifier = @"okButtonChangePass";
        [self.view addSubview:okButton];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void) triggerSave {
}

- (void) triggerResign {
    [self.view endEditing:YES];
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

//
//  UpdateMsisdnController.m
//  Depo
//
//  Created by Mahir Tarlan on 10/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "UpdateMsisdnController.h"
#import "Util.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface UpdateMsisdnController ()

@end

@implementation UpdateMsisdnController

@synthesize updatedNumberField;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"ChangeGsmNumber", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, 30, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];
        
        LoginTextfield *emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:@""];
        emailField.text = APPDELEGATE.session.user.email;
        [emailField setUserInteractionEnabled:NO];
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:emailField];

        CustomLabel *oldPhoneLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, emailField.frame.origin.y + emailField.frame.size.height + 20, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"OldPhoneLabel", @"")];
        [self.view addSubview:oldPhoneLabel];
        
        LoginTextfield *oldPhoneValue = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, oldPhoneLabel.frame.origin.y + oldPhoneLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:@""];
        oldPhoneValue.text = APPDELEGATE.session.user.username;
        [oldPhoneValue setUserInteractionEnabled:NO];
        oldPhoneValue.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:oldPhoneValue];

        CustomLabel *newPhoneLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, oldPhoneValue.frame.origin.y + oldPhoneValue.frame.size.height + 20, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"NewPhoneLabel", @"")];
        [self.view addSubview:newPhoneLabel];

        updatedNumberField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, newPhoneLabel.frame.origin.y + newPhoneLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"MsisdnPlaceholder", @"")];
        updatedNumberField.delegate = self;
        updatedNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:updatedNumberField];
        
        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, updatedNumberField.frame.origin.y + updatedNumberField.frame.size.height + 30, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"ChangePhoneButton", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
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

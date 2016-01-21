//
//  EmailValidationController.m
//  Depo
//
//  Created by Mahir on 08/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EmailValidationController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "LoginTextfield.h"

@interface EmailValidationController ()

@end

@implementation EmailValidationController

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SignUp", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        CustomLabel *topInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"AlmostThere", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:topInfoLabel];
        
        UIImage *iconImg = [UIImage imageNamed:@"icon_dialog_positive.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - iconImg.size.width)/2, topInfoLabel.frame.origin.y + topInfoLabel.frame.size.height + 10, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self.view addSubview:iconView];
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, iconView.frame.origin.y + iconView.frame.size.height + 10, self.view.frame.size.width-40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"EmailFieldRegistrationInfo", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:subInfoLabel];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, subInfoLabel.frame.origin.y + subInfoLabel.frame.size.height + 10, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"EmailTitle", @"")];
        [self.view addSubview:emailLabel];
        
        LoginTextfield *emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 5, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"EmailPlaceholder", @"")];
        [self.view addSubview:emailField];

        SimpleButton *okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, emailField.frame.origin.y + emailField.frame.size.height + 10, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [self.view addSubview:okButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end

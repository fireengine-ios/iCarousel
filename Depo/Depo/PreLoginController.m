//
//  PreLoginController.m
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PreLoginController.h"
#import "Util.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "SimpleButton.h"
#import "AppDelegate.h"

@interface PreLoginController ()

@end

@implementation PreLoginController

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        CustomButton *videoButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 50, 320, 200) withImageName:@"video_tour.png"];
        [self.view addSubview:videoButton];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 270, self.view.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"AppTitleRef", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:titleLabel];
        
        NSString *descStr = NSLocalizedString(@"AppPreLoginInfo", @"");
        UIFont *descFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:16];
        
        int descHeight = [Util calculateHeightForText:descStr forWidth:self.view.frame.size.width-40 forFont:descFont] + 5;
        
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 295, self.view.frame.size.width - 40, descHeight) withFont:descFont withColor:[Util UIColorForHexColor:@"b7ddef"] withText:descStr withAlignment:NSTextAlignmentCenter];
        descLabel.numberOfLines = 0;
        [self.view addSubview:descLabel];

        SimpleButton *loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Login", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        
    }
    return self;
}

- (void) loginClicked {
    [APPDELEGATE triggerLogin];
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

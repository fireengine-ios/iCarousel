//
//  ReachUsController.m
//  Depo
//
//  Created by Mahir Tarlan on 04/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ReachUsController.h"
#import "SimpleButton.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppUtil.h"

@interface ReachUsController ()

@end

@implementation ReachUsController

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"ReachUsTitle", @"");

        float yIndex = (IS_IPAD ? 50 : IS_IPHONE_5 ? 20 : 0);
        
        if(![AppUtil isAlreadyRated]) {
            SimpleButton *rateButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150)/2, yIndex, 150, 44) withTitle:NSLocalizedString(@"RateButton", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:22];
            [rateButton addTarget:self action:@selector(triggerRateUs) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:rateButton];
        }
        yIndex += 70;

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ReachUsInfo", @"")];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:titleLabel];

        yIndex += 40;
    }
    return self;
}

- (void) triggerRateUs {
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

//
//  PostLoginSyncPrefController.m
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginSyncPrefController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppDelegate.h"

@interface PostLoginSyncPrefController ()

@end

@implementation PostLoginSyncPrefController

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        UIImage *syncImg = [UIImage imageNamed:@"sync_prefs.png"];
        
        UIImageView *syncImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - syncImg.size.width)/2, 50, syncImg.size.width, syncImg.size.height)];
        syncImgView.image = syncImg;
        [self.view addSubview:syncImgView];
        
        CustomLabel *mainTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 20, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"PostLoginSyncPrefTitle", @"")];
        [self.view addSubview:mainTitleLabel];
        
        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [continueButton addTarget:self action:@selector(continueClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:continueButton];
        
    }
    return self;
}

- (void) continueClicked {
    [APPDELEGATE triggerHome];
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

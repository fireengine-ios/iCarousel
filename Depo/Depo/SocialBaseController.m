//
//  SocialBaseController.m
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SocialBaseController.h"

@interface SocialBaseController ()

@end

@implementation SocialBaseController

@synthesize mainStatusView;
@synthesize percentLabel;
@synthesize resultTable;

- (id) init {
    if(self = [super init]) {
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

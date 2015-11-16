//
//  BaseBgController.m
//  Depo
//
//  Created by Mahir on 09/11/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "BaseBgController.h"
#import "AppConstants.h"

@interface BaseBgController ()

@end

@implementation BaseBgController

- (id) init {
    if(self = [super init]) {
        UIImage *bgImg = [UIImage imageNamed:@"Default.png"];
        if(IS_IPHONE_5) {
            bgImg = [UIImage imageNamed:@"Default-568h@2x.png"];
        }
        UIImageView *bgImgView = [[UIImageView alloc] initWithImage:bgImg];
        bgImgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:bgImgView];
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

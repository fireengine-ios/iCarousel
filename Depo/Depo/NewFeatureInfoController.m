//
//  NewFeatureInfoController.m
//  Depo
//
//  Created by Mahir Tarlan on 10/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "NewFeatureInfoController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "SimpleButton.h"
#import "AppConstants.h"

@interface NewFeatureInfoController ()

@end

@implementation NewFeatureInfoController

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        UIImage *bgImg = [UIImage imageNamed:@"img_lifebox.png"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - bgImg.size.width)/2, IS_IPHONE_4_OR_LESS ? 30 : 60, bgImg.size.width, bgImg.size.height)];
        bgImgView.image = bgImg;
        [self.view addSubview:bgImgView];
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, bgImgView.frame.origin.y + bgImgView.frame.size.height + (IS_IPHONE_4_OR_LESS ? 5 : 20), self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"333333"] withText:NSLocalizedString(@"NewFeatureInfoLabel", @"") withAlignment:NSTextAlignmentCenter numberOfLines:1];
        [self.view addSubview:infoLabel];

        NSString *subInfoText = NSLocalizedString(@"NewFeatureInfoSubLabel", @"");
        float subInfoHeight = [Util calculateHeightForText:subInfoText forWidth:self.view.frame.size.width - 40 forFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16]] + 10;
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.origin.y + infoLabel.frame.size.height, self.view.frame.size.width - 40, subInfoHeight) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:subInfoText withAlignment:NSTextAlignmentCenter numberOfLines:0];
        [self.view addSubview:subInfoLabel];

        SimpleButton *dismissButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, self.view.frame.size.height - 80, 200, 60) withTitle:NSLocalizedString(@"Continue", "") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.isAccessibilityElement = YES;
        dismissButton.accessibilityIdentifier = @"dismissButtonNewFeature";
        [self.view addSubview:dismissButton];
    }
    return self;
}

- (void) dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
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

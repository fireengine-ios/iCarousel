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
#import "PreLoginInfoView.h"
#import "MPush.h"

@interface PreLoginController ()

@end

@implementation PreLoginController

@synthesize infoScroll;
@synthesize pageControl;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 29)/2, 28, 29, 20)];
        iconImgView.image = [UIImage imageNamed:@"cloud_icon.png"];
        [self.view addSubview:iconImgView];

        infoScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, IS_IPHONE_5 ? 80 : 45, self.view.frame.size.width, 350)];
        infoScroll.pagingEnabled = YES;
        infoScroll.showsHorizontalScrollIndicator = NO;
        infoScroll.delegate = self;
        [self.view addSubview:infoScroll];
        
        if(IS_IPAD) {
            infoScroll.frame = CGRectMake(0, (self.view.frame.size.height - 350)/2 - 50, self.view.frame.size.width, 350);
        }

        PreLoginInfoView *firstInfoView = [[PreLoginInfoView alloc] initWithFrame:CGRectMake(10, 0, infoScroll.frame.size.width - 20, infoScroll.frame.size.height) withImageName:@"pre_login_info1.png" withTitleKey:@"PreLoginTitle1" withInfoKey:@"PreLoginInfo1"];
        [infoScroll addSubview:firstInfoView];
        
        PreLoginInfoView *secondInfoView = [[PreLoginInfoView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width + 10, 0, infoScroll.frame.size.width - 20, infoScroll.frame.size.height) withImageName:@"pre_login_info2.png" withTitleKey:@"PreLoginTitle2" withInfoKey:@"PreLoginInfo2"];
        [infoScroll addSubview:secondInfoView];

        PreLoginInfoView *thirdInfoView = [[PreLoginInfoView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 2 + 10, 0, infoScroll.frame.size.width - 20, infoScroll.frame.size.height) withImageName:@"pre_login_info3.png" withTitleKey:@"PreLoginTitle3" withInfoKey:@"PreLoginInfo3"];
        [infoScroll addSubview:thirdInfoView];

        PreLoginInfoView *fourthInfoView = [[PreLoginInfoView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 3 + 10, 0, infoScroll.frame.size.width - 20, infoScroll.frame.size.height) withImageName:@"pre_login_info4.png" withTitleKey:@"PreLoginTitle4" withInfoKey:@"PreLoginInfo4"];
        [infoScroll addSubview:fourthInfoView];

        PreLoginInfoView *fifthInfoView = [[PreLoginInfoView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 4 + 10, 0, infoScroll.frame.size.width - 20, infoScroll.frame.size.height) withImageName:@"pre_login_info5.png" withTitleKey:@"PreLoginTitle5" withInfoKey:@"PreLoginInfo5"];
        [infoScroll addSubview:fifthInfoView];
        
        infoScroll.contentSize = CGSizeMake(infoScroll.frame.size.width * 5, infoScroll.frame.size.height);

        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, infoScroll.frame.origin.y + infoScroll.frame.size.height, 100, 30)];
        pageControl.numberOfPages = 5;
        pageControl.currentPage = 0;
        [self.view addSubview:pageControl];

        /*
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
        */

        SimpleButton *loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 60, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"StartUsingTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl.currentPage = page;
}

- (void) loginClicked {
    [[CurioSDK shared] sendEvent:@"GetStarted" eventValue:@"clicked"];
    [MPush hitTag:@"GetStarted" withValue:@"clicked"];
    [APPDELEGATE triggerLogin];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CurioSDK shared] sendEvent:@"TutorialPage" eventValue:@"shown"];
    [MPush hitTag:@"TutorialPage" withValue:@"shown"];
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

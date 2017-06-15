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
#import "WelcomePageView.h"

@interface PreLoginController ()

@end

@implementation PreLoginController

@synthesize infoScroll;
@synthesize pageControl;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        infoScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        infoScroll.pagingEnabled = YES;
        infoScroll.showsHorizontalScrollIndicator = NO;
        infoScroll.delegate = self;
        [self.view addSubview:infoScroll];
        
        WelcomePageView *firstView = [[WelcomePageView alloc] initWithFrame:CGRectMake(0, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_1.jpg" withTitle:NSLocalizedString(@"Welcome1Info", @"") withSubTitle:NSLocalizedString(@"Welcome1SubInfo", @"") withIcon:@"vect_mtour_1.png"];
        [infoScroll addSubview:firstView];

        WelcomePageView *secondView = [[WelcomePageView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_2.jpg" withTitle:NSLocalizedString(@"Welcome2Info", @"") withSubTitle:NSLocalizedString(@"Welcome2SubInfo", @"") withIcon:@"vect_mtour_2.png"];
        [infoScroll addSubview:secondView];
        
        WelcomePageView *thirdView = [[WelcomePageView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 2, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_3.jpg" withTitle:NSLocalizedString(@"Welcome3Info", @"") withSubTitle:NSLocalizedString(@"Welcome3SubInfo", @"") withIcon:@"vect_mtour_3.png"];
        [infoScroll addSubview:thirdView];

        WelcomePageView *fourthView = [[WelcomePageView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 3, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_4.jpg" withTitle:NSLocalizedString(@"Welcome4Info", @"") withSubTitle:NSLocalizedString(@"Welcome4SubInfo", @"") withIcon:@"vect_mtour_4.png"];
        [infoScroll addSubview:fourthView];

        WelcomePageView *fifthView = [[WelcomePageView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 4, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_5.jpg" withTitle:NSLocalizedString(@"Welcome5Info", @"") withSubTitle:NSLocalizedString(@"Welcome5SubInfo", @"") withIcon:@"vect_mtour_5.png"];
        [infoScroll addSubview:fifthView];

        WelcomePageView *sixthView = [[WelcomePageView alloc] initWithFrame:CGRectMake(infoScroll.frame.size.width * 5, 0, infoScroll.frame.size.width, infoScroll.frame.size.height) withBgImageName:@"bg_mtour_6.jpg" withTitle:NSLocalizedString(@"Welcome6Info", @"") withSubTitle:NSLocalizedString(@"Welcome6SubInfo", @"") withIcon:@"vect_mtour_6.png"];
        [infoScroll addSubview:sixthView];
        
        infoScroll.contentSize = CGSizeMake(infoScroll.frame.size.width * 6, infoScroll.frame.size.height);

        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80)/2, 28, 80, 30)];
        iconImgView.image = [UIImage imageNamed:@"logo_lifebox.png"];
        [self.view addSubview:iconImgView];

        SimpleButton *loginButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 60, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"StartUsingTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        loginButton.isAccessibilityElement = YES;
        loginButton.accessibilityIdentifier = @"loginButtonPreLogin";
        [self.view addSubview:loginButton];

        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, loginButton.frame.origin.y - 40, 100, 30)];
        pageControl.numberOfPages = 6;
        pageControl.currentPage = 0;
        pageControl.isAccessibilityElement = YES;
        pageControl.accessibilityIdentifier = @"pageControlPreLogin";
        [self.view addSubview:pageControl];

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

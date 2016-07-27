//
//  PromotionEntryController.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "PromotionEntryController.h"
#import "CustomButton.h"
#import "PromotionsController.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppDelegate.h"

@interface PromotionEntryController ()

@end

@implementation PromotionEntryController

@synthesize promoField;
@synthesize activateDao;
@synthesize mainScroll;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"MenuPromo", @"");

        activateDao = [[PromoCodeActivateDao alloc] init];
        activateDao.delegate = self;
        activateDao.successMethod = @selector(promoActivateSuccess);
        activateDao.failMethod = @selector(promoActivateFail:);
        
        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:mainScroll];
        
        float yIndex = 30;
        
        CustomLabel *titleTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"PromotionTopTitle", @"") withAlignment:NSTextAlignmentCenter];
        [mainScroll addSubview:titleTitle];
        
        yIndex += 40;
        
//        UIFont *subTitleFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:15];
//        float subTitleHeight = [Util calculateHeightForText:NSLocalizedString(@"PromotionSubTitle", @"") forWidth:mainScroll.frame.size.width - 40 forFont:subTitleFont] + 10;
        
//        CustomLabel *subTitleTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, subTitleHeight) withFont:subTitleFont withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"PromotionSubTitle", @"") withAlignment:NSTextAlignmentCenter numberOfLines:0];
//        [mainScroll addSubview:subTitleTitle];

//        yIndex += subTitleHeight + 20;
        
        promoField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 50) withPlaceholder:NSLocalizedString(@"PromoCodePlaceholder", @"")];
        [mainScroll addSubview:promoField];

        yIndex += 70;

        CustomButton *activateButton = [[CustomButton alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"ApplyButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [activateButton addTarget:self action:@selector(triggerActivate) forControlEvents:UIControlEventTouchUpInside];
        [mainScroll addSubview:activateButton];

        yIndex += 80;

        /*
        CustomLabel *infoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"LegalNotice", @"")];
        [mainScroll addSubview:infoTitle];

        yIndex += 30;

        UIFont *infoContentFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:14];
        float infoContentHeight = [Util calculateHeightForText:NSLocalizedString(@"LegalNoticeContent", @"") forWidth:mainScroll.frame.size.width - 40 forFont:infoContentFont] + 10;

        CustomLabel *infoContent = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, mainScroll.frame.size.width - 40, infoContentHeight) withFont:infoContentFont withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"LegalNoticeContent", @"") withAlignment:NSTextAlignmentLeft numberOfLines:0];
        [mainScroll addSubview:infoContent];

        yIndex += infoContentHeight + 20;
         */
        
        mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, yIndex);

    }
    return self;
}

- (void) triggerActivate {
    if([promoField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"PromoCodeEmpty", @"")];
        return;
    }
    [activateDao requestActivateCode:promoField.text];
    [self showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CustomButton *historyButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20) withImageName:@"recent_activity_icon.png"];
    [historyButton addTarget:self action:@selector(historyClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:historyButton];
//    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void) historyClicked {
    PromotionsController *historyController = [[PromotionsController alloc] init];
    [self.nav pushViewController:historyController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) promoActivateSuccess {
    [self hideLoading];
    [self showInfoAlertWithMessage:NSLocalizedString(@"PromoSuccess", @"")];
    [self.view endEditing:YES];
    [self.nav popViewControllerAnimated:YES];
}

- (void) promoActivateFail:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
    [self.view endEditing:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
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

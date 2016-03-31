//
//  TermsController.m
//  Depo
//
//  Created by Mahir on 01/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "TermsController.h"
#import "Util.h"
#import "AppDelegate.h"

@interface TermsController ()

@end

@implementation TermsController

@synthesize webView;
@synthesize checkButton;
@synthesize provisionDao;
@synthesize acceptButton;
@synthesize eulaDao;
@synthesize eulaApproveDao;
@synthesize eula;

- (id) init {
    return [self initWithCheckEnabled:YES];
}

- (id) initWithCheckEnabled:(BOOL) checkEnabled {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.title = NSLocalizedString(@"TermsTitle", @"");
        
        provisionDao = [[ProvisionDao alloc] init];
        provisionDao.delegate = self;
        provisionDao.successMethod = @selector(provisionSuccessCallback);
        provisionDao.failMethod = @selector(provisionFailCallback:);
        
        eulaDao = [[EulaDao alloc] init];
        eulaDao.delegate = self;
        eulaDao.successMethod = @selector(eulaReadSuccessCallback:);
        eulaDao.failMethod = @selector(eulaReadFailCallback:);

        eulaApproveDao = [[EulaApproveDao alloc] init];
        eulaApproveDao.delegate = self;
        eulaApproveDao.successMethod = @selector(eulaApproveSuccessCallback);
        eulaApproveDao.failMethod = @selector(eulaApproveFailCallback:);
        
        UIImage *topImg = [UIImage imageNamed:@"bulutheader.png"];
        float imageHeight = (self.view.frame.size.width/topImg.size.width)*topImg.size.height;
        
        UIImageView *topImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, imageHeight)];
        topImgView.image = topImg;
        [self.view addSubview:topImgView];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, topImgView.frame.size.height + 10, self.view.frame.size.width - 20, self.view.frame.size.height - topImgView.frame.size.height - (checkEnabled ? 110 : 50))];
        webView.delegate = self;
        webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:webView];

        if(checkEnabled) {
            checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, webView.frame.origin.y + webView.frame.size.height + 10, self.view.frame.size.width - 30, 25) withTitle:NSLocalizedString(@"AcceptTerms", @"") isInitiallyChecked:NO];
            checkButton.checkDelegate = self;
            [self.view addSubview:checkButton];

            acceptButton = [[SimpleButton alloc] initWithFrame:CGRectMake(15, checkButton.frame.origin.y + checkButton.frame.size.height + 5, self.view.frame.size.width - 30, 52) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:22] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
            [acceptButton addTarget:self action:@selector(triggerNext) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:acceptButton];
        }
        
        [eulaDao requestEulaForLocale:[Util readLocaleCode]];
        [self showLoading];
    }
    return self;
}

- (void) triggerNext {
    if(checkButton.isChecked) {
        [provisionDao requestSendProvision];
        [self showLoading];
    } else {
        [self showInfoAlertWithMessage:NSLocalizedString(@"AcceptTermsWarning", @"")];
    }
}

- (void) provisionSuccessCallback {
    [eulaApproveDao requestApproveEulaForId:self.eula.eulaId];
}

- (void) provisionFailCallback:(NSString *) errorMessage {
    [eulaApproveDao requestApproveEulaForId:self.eula.eulaId];
}

- (void) eulaReadSuccessCallback:(Eula *) eulaRead {
    self.eula = eulaRead;
    [self hideLoading];

    [webView loadHTMLString:self.eula.content baseURL:[NSURL URLWithString:@"http://www.turkcell.com.tr"]];
}

- (void) eulaReadFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

#pragma mark CheckButtonDelegate methods

- (void) checkButtonWasChecked {
    acceptButton.enabled = YES;
}

- (void) checkButtonWasUnchecked {
    acceptButton.enabled = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) eulaApproveSuccessCallback {
    [self hideLoading];
    [APPDELEGATE triggerPostTermsAndMigration];
    [self.view removeFromSuperview];
}

- (void) eulaApproveFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
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

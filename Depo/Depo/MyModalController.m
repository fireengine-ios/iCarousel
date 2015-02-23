//
//  MyModalController.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "AppConstants.h"
#import "CustomAlertView.h"
#import "AppDelegate.h"
#import "CurioSDK.h"
#import "MapUtil.h"

@interface MyModalController ()

@end

@implementation MyModalController

@synthesize topIndex;
@synthesize bottomIndex;
@synthesize processView;
@synthesize nav;
@synthesize progress;

- (id)init {
    self = [super init];
    if (self) {
        if(IS_BELOW_7) {
            topIndex = 0;
            bottomIndex = 44;
        } else {
            topIndex = 0;
            bottomIndex = 64;
        }
        progress = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        progress.opacity = 0.4f;
        [self.view addSubview:progress];
    }
    return self;
}

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showErrorAlertWithMessage:(NSString *) errMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:@"Hata" withMessage:errMessage withModalType:ModalTypeError];
    [APPDELEGATE showCustomAlert:alert];
}

- (void) showInfoAlertWithMessage:(NSString *) infoMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:@"Bilgi" withMessage:infoMessage withModalType:ModalTypeSuccess];
    [APPDELEGATE showCustomAlert:alert];
}

- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg {
    if(processView) {
        [processView removeFromSuperview];
    }
    
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) withProcessMessage:progressMsg withFinalMessage:successMsg withFailMessage:failMsg];
    processView.delegate = self;
    [self.view addSubview:processView];
    [self.view bringSubviewToFront:processView];
    
    [processView startLoading];
}

#pragma mark ProcessFooterDelegate

- (void) processFooterShouldDismiss {
}

- (void) popProgressView {
    if(processView) {
        [processView removeFromSuperview];
    }
}

- (void) showLoading {
    [progress show:YES];
    [self.view bringSubviewToFront:progress];
}

- (void) hideLoading {
    [progress hide:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *curioValForController = [APPDELEGATE.mapUtil readCurioValueByController:NSStringFromClass(self.class)];
    if(curioValForController != nil) {
        [[CurioSDK shared] startScreen:[self class] title:curioValForController path:curioValForController];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[CurioSDK shared] endScreen:[self class]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)fadeIn:(UIView *)view duration:(float)duration {
    view.alpha = 0;
    view.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) { }];
}

- (void)fadeOut:(UIView *)view duration:(float)duration {
    view.alpha = 1;
    view.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}


- (void) proceedSuccessForProgressView {
    if(processView) {
        [processView showMessageForSuccess];
    }
}

- (void) proceedSuccessForProgressViewWithAddButtonKey:(NSString *) buttonKey {
    if(processView) {
        [processView showMessageForSuccessWithPostButtonKey:buttonKey];
    }
}

- (void) proceedFailureForProgressView {
    if(processView) {
        [processView showMessageForFailure];
    }
}

- (void) proceedFailureForProgressViewWithAddButtonKey:(NSString *) buttonKey {
    if(processView) {
        [processView showMessageForFailureWithPostButtonKey:buttonKey];
    }
}

@end

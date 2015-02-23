//
//  MyModalController.h
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProcessFooterView.h"
#import "CustomButton.h"
#import "MyNavigationController.h"
#import "MBProgressHUD.h"

@interface MyModalController : UIViewController <ProcessFooterDelegate>

@property (nonatomic) int topIndex;
@property (nonatomic) int bottomIndex;
@property (nonatomic, strong) ProcessFooterView *processView;
@property (nonatomic, strong) MyNavigationController *nav;
@property (nonatomic, strong) MBProgressHUD *progress;

- (void) triggerDismiss;
- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg;
- (void) showLoading;
- (void) hideLoading;
- (void)fadeIn:(UIView *)view duration:(float)duration;
- (void)fadeOut:(UIView *)view duration:(float)duration;
- (void) showErrorAlertWithMessage:(NSString *) errMessage;
- (void) proceedSuccessForProgressView;
- (void) proceedSuccessForProgressViewWithAddButtonKey:(NSString *) buttonKey;
- (void) proceedFailureForProgressView;
- (void) proceedFailureForProgressViewWithAddButtonKey:(NSString *) buttonKey;


@end

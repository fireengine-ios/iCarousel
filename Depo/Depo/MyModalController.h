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

@interface MyModalController : UIViewController

@property (nonatomic) int topIndex;
@property (nonatomic) int bottomIndex;
@property (nonatomic, strong) ProcessFooterView *processView;
@property (nonatomic, strong) MyNavigationController *nav;

- (void) triggerDismiss;
- (void) pushProgressViewWithProcessMessage:(NSString *) progressMsg andSuccessMessage:(NSString *) successMsg andFailMessage:(NSString *) failMsg;
- (void) showLoading;
- (void) hideLoading;

@end

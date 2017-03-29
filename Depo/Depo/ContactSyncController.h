//
//  ContactSyncController.h
//  Depo
//
//  Created by Mahir on 06/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "CustomLabel.h"
#import "ProcessFooterView.h"
#import "XYPieChart.h"
#import "ContactSyncProgressView.h"
#import "ContactSyncView.h"
#import "ContactSyncResultView.h"

@interface ContactSyncController : MyViewController <ProcessFooterDelegate, XYPieChartDelegate, XYPieChartDataSource, ContactSyncViewDelegate>

@property (nonatomic) EnableOption oldSyncOption;
@property (nonatomic, strong) SimpleButton *backupButton;
@property (nonatomic, strong) SimpleButton *restoreButton;
@property (nonatomic, strong) CustomLabel *lastSyncDateLabel;
@property (nonatomic, strong) UIView *topContainer;

@property (nonatomic,strong) NSMutableArray *statusList;
@property (nonatomic,strong) NSArray *statusColors;
@property (nonatomic,strong) ContactSyncView *syncView;
@property (nonatomic,strong) ContactSyncProgressView *progressView;
@property (nonatomic,strong) ContactSyncResultView *syncResultView;
@property (nonatomic,strong) XYPieChart *myPieChart;
@property (nonatomic) int processPercent;
@property (nonatomic,strong) CustomLabel *syncTargetLabel;

@end

//
//  DropboxExportController.h
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "XYPieChart.h"
#import "CustomLabel.h"
#import "DropboxStartDao.h"
#import "DropboxConnectDao.h"
#import "DropboxStatusDao.h"
#import "DropboxTokenDao.h"
#import <DropboxSDK/DropboxSDK.h>
//#import "CustomConfirmView.h"


@interface DropboxExportController : MyViewController <XYPieChartDelegate, XYPieChartDataSource, UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate/*, CustomConfirmDelegate*/>

@property (nonatomic, strong) UIView *mainStatusView;

@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) CustomLabel *percentLabel;
@property (nonatomic, strong) XYPieChart *statusChart;
@property (nonatomic, strong) NSMutableArray *statusList;
@property (nonatomic, strong) NSArray *statusColors;

@property (nonatomic, strong) UITableView *resultTable;

@property (nonatomic, strong) DropboxConnectDao *connectDao;
@property (nonatomic, strong) DropboxStartDao *startDao;
@property (nonatomic, strong) DropboxStatusDao *statusDao;
@property (nonatomic, strong) DropboxTokenDao *tokenDao;

@end

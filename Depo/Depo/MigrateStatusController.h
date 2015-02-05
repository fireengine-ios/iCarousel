//
//  MigrateStatusController.h
//  Depo
//
//  Created by Mahir on 01/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "CustomLabel.h"
#import "XYPieChart.h"
#import "MigrateStatusDao.h"
#import "MigrateDao.h"

@interface MigrateStatusController : MyModalController <XYPieChartDelegate, XYPieChartDataSource>

@property (nonatomic, strong) MigrateStatusDao *statusDao;
@property (nonatomic, strong) MigrateDao *migrateDao;
@property (nonatomic, strong) UIImageView *circleView;
@property (nonatomic, strong) CustomLabel *percentLabel;
@property (nonatomic, strong) XYPieChart *statusChart;
@property (nonatomic, strong) NSMutableArray *statusList;
@property (nonatomic, strong) NSArray *statusColors;

@end

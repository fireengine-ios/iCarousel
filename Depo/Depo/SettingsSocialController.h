//
//  SettingsSocialController.h
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FBPermissionDao.h"
#import "FBConnectDao.h"
#import "TitleWithSwitchCell.h"
#import "FBStatusDao.h"
#import "FBStartDao.h"
#import "FBStopDao.h"

@interface SettingsSocialController : MyViewController <UITableViewDataSource, UITableViewDelegate, TitleWithSwitchDelegate>

@property (nonatomic, strong) UITableView *mainTable;
@property (nonatomic, strong) FBPermissionDao *fbPermissionDao;
@property (nonatomic, strong) FBConnectDao *fbConnectDao;
@property (nonatomic, strong) FBStatusDao *fbStatusDao;
@property (nonatomic, strong) FBStartDao *fbStartDao;
@property (nonatomic, strong) FBStopDao *fbStopDao;

@end

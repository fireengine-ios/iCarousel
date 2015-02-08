//
//  ContactSyncController.h
//  Depo
//
//  Created by Mahir on 06/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "CustomLabel.h"

@interface ContactSyncController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISwitch *autoSyncSwitch;
@property (nonatomic, strong) CustomLabel *lastSyncDateLabel;
@property (nonatomic, strong) UITableView *lastSyncDetailTable;

@end

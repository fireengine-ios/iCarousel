//
//  PostLoginSyncPrefController.h
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"

@interface PostLoginSyncPrefController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISwitch *onOff;
@property (nonatomic, strong) UITableView *choiceTable;
@property (nonatomic, strong) NSMutableArray *choices;

@end

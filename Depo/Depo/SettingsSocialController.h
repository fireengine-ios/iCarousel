//
//  SettingsSocialController.h
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"

@interface SettingsSocialController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *mainTable;

@end

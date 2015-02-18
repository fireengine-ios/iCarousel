//
//  PostLoginSyncPrefController.h
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostLoginSyncPrefController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISwitch *onOff1;
@property (nonatomic, strong) UISwitch *onOff2;
@property (nonatomic, strong) UITableView *choiceTable;
@property (nonatomic, strong) NSMutableArray *choices;
@property (nonatomic) ConnectionOption selectedOption;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

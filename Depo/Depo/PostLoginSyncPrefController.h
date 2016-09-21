//
//  PostLoginSyncPrefController.h
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PostLoginPrefCell.h"
#import "LocationManager.h"
#import "TTTAttributedLabel.h"
#import "CustomInfoWithIconView.h"
#import "CustomAlertView.h"

@interface PostLoginSyncPrefController : MyViewController <UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate, TTTAttributedLabelDelegate, CustomInfoWithIconDelegate, CustomAlertDelegate>

@property (nonatomic, strong) UISwitch *autoSyncSwitch;
@property (nonatomic, strong) CustomLabel *choiceTitleLabel;
@property (nonatomic, strong) UITableView *choiceTable;
@property (nonatomic, strong) NSMutableArray *choices;
@property (nonatomic) ConnectionOption selectedOption;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) PostLoginPrefCell *wifi3gCell;
@property (nonatomic, strong) CustomInfoWithIconView *locInfoPopup;

@end

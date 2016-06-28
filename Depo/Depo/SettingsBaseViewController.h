//
//  SettingsBaseViewController.h
//  Depo
//
//  Created by Salih Topcu on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "AppConstants.h"
#import "CacheUtil.h"
#import "Util.h"
#import "TitleCell.h"
#import "HeaderCell.h"
#import "TextCell.h"

@interface SettingsBaseViewController : MyViewController <UITableViewDataSource, UITabBarControllerDelegate> {
    int currentSetting;
    int oldSetting;
}

@property (nonatomic, strong) UITableView *pageContentTable;

- (void)drawPageContentTable;
- (void)setAuto;
- (void)setOn;
- (void)setOff;
- (NSString *) getEnableOptionName:(int)value;

@end

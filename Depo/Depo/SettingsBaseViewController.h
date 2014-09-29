//
//  SettingsBaseViewController.h
//  Depo
//
//  Created by Mustafa Talha Celik on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseViewController.h"
#import "AppConstants.h"
#import "Util.h"
#import "TitleCell.h"
#import "HeaderCell.h"
#import "TextCell.h"

@interface SettingsBaseViewController : BaseViewController <UITableViewDataSource, UITabBarControllerDelegate> {
    UITableView *pageContentTable;
    double topIndex;
}

@end

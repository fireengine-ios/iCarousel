//
//  SettingsController.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "TitleCell.h"

@interface SettingsController : MyViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *pageContentTable;
    int topIndex;
    UIView *imageOptionsArea;
    UIView *darkArea;
    UIView *popupContainer;
}

@end

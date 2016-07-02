//
//  SocialBaseController.h
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"

@interface SocialBaseController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *mainStatusView;
@property (nonatomic, strong) CustomLabel *percentLabel;
@property (nonatomic, strong) UITableView *resultTable;

@end

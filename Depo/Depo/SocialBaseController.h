//
//  SocialBaseController.h
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "CustomButton.h"
#import "SocialExportResult.h"

@interface SocialBaseController : MyViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *mainStatusView;
@property (nonatomic, strong) CustomLabel *percentLabel;
@property (nonatomic, strong) UITableView *resultTable;
@property (nonatomic, strong) CustomButton *exportButton;
@property (nonatomic, strong) SocialExportResult *recentStatus;

- (id) initWithImageName:(NSString *) imgName withMessage:(NSString *) message;

@end

//
//  PostLoginSyncPrefController.m
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginSyncPrefController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "PostLoginPrefCell.h"
#import "CacheUtil.h"
#import "AppUtil.h"

@interface PostLoginSyncPrefController ()

@end

@implementation PostLoginSyncPrefController

@synthesize onOff;
@synthesize choiceTable;
@synthesize choices;
@synthesize selectedOption;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        choices = [[NSMutableArray alloc] init];
        [choices addObject:@"Wifi + 3G"];
        [choices addObject:@"Wifi"];
        
        UIImage *syncImg = [UIImage imageNamed:@"sync_prefs.png"];
        
        UIImageView *syncImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - syncImg.size.width)/2, 50, syncImg.size.width, syncImg.size.height)];
        syncImgView.image = syncImg;
        [self.view addSubview:syncImgView];
        
        CustomLabel *mainTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + (IS_IPHONE_5 ? 30 : 10), self.view.frame.size.width - 40, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:13] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"PostLoginSyncPrefTitle", @"")];
        [self.view addSubview:mainTitleLabel];
        
        choiceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, mainTitleLabel.frame.origin.y + mainTitleLabel.frame.size.height + (IS_IPHONE_5 ? 15 : 5), self.view.frame.size.width, 80) style:UITableViewStylePlain];
        choiceTable.delegate = self;
        choiceTable.dataSource = self;
        choiceTable.bounces = NO;
        [self.view addSubview:choiceTable];

        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, choiceTable.frame.origin.y + choiceTable.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 230, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"DataRoamingTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        CustomLabel *switchSubLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, switchLabel.frame.origin.y + switchLabel.frame.size.height, 230, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:12] withColor:[Util UIColorForHexColor:@"b7ddef"] withText:NSLocalizedString(@"DataRoamingSubTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchSubLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchSubLabel];
        
        onOff = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, choiceTable.frame.origin.y + choiceTable.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 40, 20)];
        [onOff setOn:YES];
        [self.view addSubview:onOff];

        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [continueButton addTarget:self action:@selector(continueClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:continueButton];
        
    }
    return self;
}

- (void) continueClicked {
    [CacheUtil writeCachedSettingSyncingConnectionType:selectedOption];
    [CacheUtil writeCachedSettingDataRoaming:onOff.isOn];

    [AppUtil writeFirstVisitOverFlag];
    [APPDELEGATE triggerHome];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [choices count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"PREF_CELL_%d", (int) indexPath.row];
    PostLoginPrefCell *cell = [[PostLoginPrefCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:[choices objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        selectedOption = ConnectionOptionWifi3G;
    } else {
        selectedOption = ConnectionOptionWifi;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

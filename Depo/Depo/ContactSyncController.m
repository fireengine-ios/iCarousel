//
//  ContactSyncController.m
//  Depo
//
//  Created by Mahir on 06/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactSyncController.h"
#import "Util.h"
#import "SyncUtil.h"
#import "CacheUtil.h"
#import "AppUtil.h"
#import "ContactSyncResultCell.h"
#import "ContactSyncResultTitleCell.h"
#import "SimpleButton.h"
#import "ContactSyncSDK.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppConstants.h"

@interface ContactSyncController ()

@end

@implementation ContactSyncController

@synthesize autoSyncSwitch;
@synthesize lastSyncDateLabel;
@synthesize lastSyncDetailTable;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"ContactSyncTitle", @"");
        
        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 25, 230, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ContactSyncFlagTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        autoSyncSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, 25, 40, 20)];
        [autoSyncSwitch setOn:([CacheUtil readCachedSettingSyncContacts] == EnableOptionAuto || [CacheUtil readCachedSettingSyncContacts] == EnableOptionOn)];
        [self.view addSubview:autoSyncSwitch];

        SimpleButton *manuelSyncButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, 75, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"ManualSyncTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [manuelSyncButton addTarget:self action:@selector(syncClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:manuelSyncButton];

        NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
        if([SyncUtil readLastContactSyncDate] != nil) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
        }
        lastSyncDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 145, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:lastSyncTitle withAlignment:NSTextAlignmentLeft];
        [self.view addSubview:lastSyncDateLabel];
        
        lastSyncDetailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 185, self.view.frame.size.width, 230) style:UITableViewStylePlain];
        lastSyncDetailTable.backgroundColor = [UIColor clearColor];
        lastSyncDetailTable.backgroundView = nil;
        lastSyncDetailTable.delegate = self;
        lastSyncDetailTable.dataSource = self;
        lastSyncDetailTable.separatorColor = UITableViewCellSeparatorStyleNone;
        lastSyncDetailTable.bounces = NO;
        [self.view addSubview:lastSyncDetailTable];

        [SyncSettings shared].callback = ^void(void) {
            SyncStatus *status = [SyncStatus shared];
            switch (status.status) {
                case SYNC_RESULT_SUCCESS: {
                    ContactSyncResult *currentSyncResult = [[ContactSyncResult alloc] init];
                    currentSyncResult.clientUpdateCount = status.updatedContactsSent.count;
                    currentSyncResult.serverUpdateCount = status.updatedContactsReceived.count;
                    currentSyncResult.clientNewCount = status.createdContactsSent.count;
                    currentSyncResult.serverNewCount = status.createdContactsReceived.count;
                    currentSyncResult.clientDeleteCount = status.deletedContactsOnDevice.count;
                    currentSyncResult.serverDeleteCount = status.deletedContactsOnServer.count;
                    APPDELEGATE.session.syncResult = currentSyncResult;
                    [SyncUtil writeLastContactSyncResult:currentSyncResult];
                }
                    break;
                case SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"AddressBookGrantError", @"")];
                    break;
                case SYNC_RESULT_ERROR_REMOTE_SERVER:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"ContactSyncApiError", @"")];
                    break;
                case SYNC_RESULT_ERROR_NETWORK:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"ContactSyncNetworkError", @"")];
                    break;
                default:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"ContactSyncGeneralError", @"")];
                    break;
            }
            [self manualSyncFinalized];
        };
    
    }
    return self;
}

- (void) manualSyncFinalized {
    [self hideLoading];
    
    [SyncUtil updateLastContactSyncDate];
    NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
    if([SyncUtil readLastContactSyncDate] != nil) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
    }
    lastSyncDateLabel.text = lastSyncTitle;
    [lastSyncDetailTable reloadData];
}

- (void) syncClicked {
    [SyncSettings shared].token = APPDELEGATE.session.authToken;
    [SyncSettings shared].url = CONTACT_SYNC_SERVER_URL;
    [ContactSyncSDK doSync];
    [self showLoading];
}

#pragma mark UITableView methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 40;
    } else {
        return 50;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    headerView.backgroundColor = [Util UIColorForHexColor:@"f4f5f8"];
    
    CustomLabel *headerLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ContactLastSyncDetailTitle", @"") withAlignment:NSTextAlignmentLeft];
    [headerView addSubview:headerLabel];

    return headerView;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactSyncResultCellIdentifier";
    if(indexPath.row == 0) {
        return [[ContactSyncResultTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    } else if(indexPath.row == 1) {
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailUpdateTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientUpdateCount] withServerVal:[APPDELEGATE.session.syncResult serverUpdateCount]];
    } else if(indexPath.row == 2) {
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailNewTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientNewCount] withServerVal:[APPDELEGATE.session.syncResult serverNewCount]];
    } else {
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientDeleteCount] withServerVal:[APPDELEGATE.session.syncResult serverDeleteCount]];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(autoSyncSwitch.isOn) {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionAuto];
        [SyncUtil startContactAutoSync];
    } else {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
        [SyncUtil stopContactAutoSync];
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

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
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

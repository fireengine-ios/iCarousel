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

@synthesize oldSyncOption;
@synthesize backupButton;
@synthesize restoreButton;
@synthesize lastSyncDateLabel;
@synthesize lastSyncDetailTable;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"ContactSyncTitle", @"");
        
        float topIndex = IS_IPAD ? 50 : 10;
        float buttonHeight = IS_IPAD ? 80 : 50;
        
        backupButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, buttonHeight) withTitle:NSLocalizedString(@"ContactBackupButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [backupButton addTarget:self action:@selector(backupClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backupButton];

        topIndex += IS_IPAD ? (buttonHeight + 10) : buttonHeight;

        CustomLabel *backupLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10, topIndex, 300, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ContactBackupInfo", @"") withAlignment:NSTextAlignmentCenter];
        backupLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:backupLabel];

        topIndex += IS_IPAD ? 45 : 30;
        
        restoreButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, buttonHeight) withTitle:NSLocalizedString(@"ContactRestoreButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [restoreButton addTarget:self action:@selector(restoreClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:restoreButton];
        
        topIndex += IS_IPAD ? (buttonHeight + 10) : buttonHeight;
        
        CustomLabel *restoreLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, topIndex, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ContactRestoreInfo", @"") withAlignment:NSTextAlignmentCenter];
        restoreLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:restoreLabel];

        topIndex += IS_IPAD ? 60 : 40;

        NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
        if([SyncUtil readLastContactSyncDate] != nil) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
        }
        lastSyncDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:lastSyncTitle withAlignment:NSTextAlignmentLeft];
        [self.view addSubview:lastSyncDateLabel];
        
        topIndex += IS_IPAD ? 45 : 30;
        
        lastSyncDetailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topIndex, self.view.frame.size.width, self.view.frame.size.height - topIndex - 60) style:UITableViewStylePlain];
        lastSyncDetailTable.backgroundColor = [UIColor clearColor];
        lastSyncDetailTable.backgroundView = nil;
        lastSyncDetailTable.delegate = self;
        lastSyncDetailTable.dataSource = self;
        lastSyncDetailTable.separatorColor = UITableViewCellSeparatorStyleNone;
        lastSyncDetailTable.bounces = NO;
        [self.view addSubview:lastSyncDetailTable];
        
        if([SyncUtil readLastContactSyncDate] == nil) {
            lastSyncDateLabel.hidden = YES;
            lastSyncDetailTable.hidden = YES;
        }

        [SyncSettings shared].token = APPDELEGATE.session.authToken;
        [SyncSettings shared].url = CONTACT_SYNC_SERVER_URL;
        [SyncSettings shared].debug = YES;
        [SyncSettings shared].callback = ^void(id data) {
            SyncStatus *status = [SyncStatus shared];
            switch (status.status) {
                case SYNC_RESULT_SUCCESS: {
                    ContactSyncResult *currentSyncResult = [[ContactSyncResult alloc] init];
                    currentSyncResult.clientUpdateCount = (int)status.updatedContactsReceived.count;
                    currentSyncResult.serverUpdateCount = (int)status.updatedContactsSent.count;
                    currentSyncResult.clientNewCount = (int)status.createdContactsReceived.count;
                    currentSyncResult.serverNewCount = (int)status.createdContactsSent.count;
                    currentSyncResult.clientDeleteCount = (int)status.deletedContactsOnDevice.count;
                    currentSyncResult.serverDeleteCount = (int)status.deletedContactsOnServer.count;
                    currentSyncResult.syncType = APPDELEGATE.session.syncType;
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

- (void) backupClicked {
    APPDELEGATE.session.syncType = ContactSyncTypeBackup;
    [ContactSyncSDK doSync:SYNCBackup];
    [self showLoading];
}

- (void) restoreClicked {
    APPDELEGATE.session.syncType = ContactSyncTypeRestore;
    [ContactSyncSDK doSync:SYNCRestore];
    [self showLoading];
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
    lastSyncDateLabel.hidden = NO;
    [lastSyncDetailTable reloadData];
    lastSyncDetailTable.hidden = NO;
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
        return 40;
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
        NSString *sectionTitle = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? NSLocalizedString(@"ContactResultBackupSectionTitle", @"") : NSLocalizedString(@"ContactResultRestoreSectionTitle", @"");
        return [[ContactSyncResultTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:sectionTitle];
    } else if(indexPath.row == 1) {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult serverUpdateCount] : [APPDELEGATE.session.syncResult clientUpdateCount];
//        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailUpdateTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientUpdateCount] withServerVal:[APPDELEGATE.session.syncResult serverUpdateCount]];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailUpdateTitle", @"") withVal:syncVal];
    } else if(indexPath.row == 2) {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult serverNewCount] : [APPDELEGATE.session.syncResult clientNewCount];
//        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailNewTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientNewCount] withServerVal:[APPDELEGATE.session.syncResult serverNewCount]];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailNewTitle", @"") withVal:syncVal];
    } else {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult serverDeleteCount] : [APPDELEGATE.session.syncResult clientDeleteCount];
//        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientDeleteCount] withServerVal:[APPDELEGATE.session.syncResult serverDeleteCount]];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"") withVal:syncVal];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([ContactSyncSDK isRunning]) {
        [self showLoading];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /*
    if (autoSyncSwitch.isOn) {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionAuto];
        if (oldSyncOption == EnableOptionOff) {
            [SyncUtil startContactAutoSync];
        }
    } else {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
        [SyncUtil stopContactAutoSync];
    }
     */
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

@end

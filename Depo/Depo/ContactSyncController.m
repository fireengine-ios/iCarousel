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
#import "BaseViewController.h"
#import "RequestTokenDao.h"
#import "RadiusDao.h"
#import "Reachability.h"

#define tableViewHeaderHeight 40.0f
#define tableViewRowHeight 40.0f
#define tableViewRowCount 5

@interface ContactSyncController () {
//    sayfa degistirildiginde 1 saniyeligine daha ekran kalmasi icin super view'deki kullanilmadi
    ProcessFooterView *processView;
    SYNCMode syncMode;
}

@property (nonatomic, assign) BOOL triedAgain;
@property (nonatomic) NSString* errMessage;
@property (nonatomic) RequestTokenDao *tokenDao;
@property (nonatomic) RadiusDao *radiusDao;

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
        
        float topIndex = IS_IPAD ? 50 : 20;
        float buttonHeight = IS_IPAD ? 70 : 40;
        float bgHeight = (10 + buttonHeight + 10 + 20 + 10);
        float buttonWidth = buttonHeight * 4;
        float verticalPadding;
        if (IS_IPHONE_4_OR_LESS) {
            verticalPadding = 10;
        } else if (IS_IPAD) {
            verticalPadding = 50;
        } else if (IS_IPHONE_6P_OR_HIGHER) {
            verticalPadding = 30;
        } else {
            verticalPadding = 20;
        }
        
        UIView *bgViewBackup = [[UIView alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, bgHeight)];
        bgViewBackup.backgroundColor = [Util UIColorForHexColor:@"f7f6f3"];
        [self.view addSubview:bgViewBackup];
        
        backupButton = [[SimpleButton alloc] initWithFrame:CGRectMake((bgViewBackup.frame.size.width - buttonWidth) /2,
                                                                      10,
                                                                      buttonWidth,
                                                                      buttonHeight)
                                                 withTitle:NSLocalizedString(@"ContactBackupButtonTitle", @"")
                                            withTitleColor:[Util UIColorForHexColor:@"363e4f"]
                                             withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18]
                                           withBorderColor:[Util UIColorForHexColor:@"ffe000"]
                                               withBgColor:[Util UIColorForHexColor:@"ffe000"]
                                          withCornerRadius:15];
        [backupButton addTarget:self action:@selector(backupClicked) forControlEvents:UIControlEventTouchUpInside];
        [bgViewBackup addSubview:backupButton];
        
        CustomLabel *backupLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10,
                                                                                 buttonHeight + 20,
                                                                                 bgViewBackup.frame.size.width - 20,
                                                                                 20)
                                                             withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15]
                                                            withColor:[Util UIColorForHexColor:@"888888"]
                                                             withText:NSLocalizedString(@"ContactBackupInfo", @"")
                                                        withAlignment:NSTextAlignmentLeft];
        backupLabel.adjustsFontSizeToFitWidth = YES;
        [bgViewBackup addSubview:backupLabel];
        
        topIndex = topIndex + bgHeight + verticalPadding;
        
        UIView *bgViewRestore = [[UIView alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, bgHeight)];
        bgViewRestore.backgroundColor = [Util UIColorForHexColor:@"f7f6f3"];
        [self.view addSubview:bgViewRestore];
        
        restoreButton = [[SimpleButton alloc] initWithFrame:CGRectMake((bgViewBackup.frame.size.width - buttonWidth) /2,
                                                                       10,
                                                                       buttonWidth,
                                                                       buttonHeight)
                                                  withTitle:NSLocalizedString(@"ContactRestoreButtonTitle", @"")
                                             withTitleColor:[Util UIColorForHexColor:@"363e4f"]
                                              withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18]
                                            withBorderColor:[Util UIColorForHexColor:@"ffe000"]
                                                withBgColor:[Util UIColorForHexColor:@"ffe000"]
                                           withCornerRadius:15];
        [restoreButton addTarget:self action:@selector(restoreClicked) forControlEvents:UIControlEventTouchUpInside];
        [bgViewRestore addSubview:restoreButton];
        
        CustomLabel *restoreLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10,
                                                                                  buttonHeight + 20,
                                                                                  bgViewRestore.frame.size.width - 20,
                                                                                  20)
                                                              withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15]
                                                             withColor:[Util UIColorForHexColor:@"888888"]
                                                              withText:NSLocalizedString(@"ContactRestoreInfo", @"")
                                                         withAlignment:NSTextAlignmentLeft];
        restoreLabel.adjustsFontSizeToFitWidth = YES;
        [bgViewRestore addSubview:restoreLabel];
        
        topIndex = topIndex + bgHeight + (IS_IPHONE_5? 10 : verticalPadding);
        
        NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
        if([SyncUtil readLastContactSyncDate] != nil) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
        }
        lastSyncDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, topIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:lastSyncTitle withAlignment:NSTextAlignmentLeft];
        [self.view addSubview:lastSyncDateLabel];
        NSLog(@"%@", lastSyncTitle);
        
        topIndex += IS_IPAD ? 45 : 30;
        
        CGFloat tableViewHeight = MIN(self.view.frame.size.height - topIndex - 60, (tableViewRowCount * tableViewRowHeight) + tableViewHeaderHeight);
        lastSyncDetailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topIndex, self.view.frame.size.width, tableViewHeight) style:UITableViewStylePlain];
        
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
        } else {
            APPDELEGATE.session.syncResult = [ContactSyncResult loadData];;
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
                    currentSyncResult.totalContactOnClient = [status.totalContactOnClient intValue];
                    currentSyncResult.totalContactOnServer = [status.totalContactOnServer intValue];
                    currentSyncResult.syncType = APPDELEGATE.session.syncType;
                    [currentSyncResult saveData];
                    APPDELEGATE.session.syncResult = currentSyncResult;
                    [SyncUtil writeLastContactSyncResult:currentSyncResult];
                }
                    break;
                case SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"AddressBookGrantError", @"")];
                    break;
                    
                    
                case SYNC_RESULT_ERROR_REMOTE_SERVER:
                    _errMessage = @"ContactSyncApiError";
                    
                case SYNC_RESULT_ERROR_NETWORK:
                    _errMessage = @"ContactSyncGeneralError";
                    
                default:
                    if (_triedAgain == NO) {
                        APPDELEGATE.session.authToken = nil;
                        _triedAgain = YES;
                        [self triggerNewToken];
                    } else {
                        [self showErrorAlertWithMessage:NSLocalizedString(_errMessage, @"")];
                        [self hideProcessView];
                        [self makeButtonsActive];
                    }
                    
                    return;
            }
            [self manualSyncFinalized];
        };
    }
    return self;
}

- (void) backupClicked {
    IGLog(@"ContactSync backup started");
    APPDELEGATE.session.syncType = ContactSyncTypeBackup;
    _triedAgain = NO;
    [ContactSyncSDK doSync:SYNCBackup];
    syncMode = SYNCBackup;
    
    [self showProcessView];
    [self makeButtonsPassive];
}

- (void) restoreClicked {
    IGLog(@"ContactSync restore started");
    APPDELEGATE.session.syncType = ContactSyncTypeRestore;
    _triedAgain = NO;
    [ContactSyncSDK doSync:SYNCRestore];
    syncMode = SYNCRestore;
    
    [self showProcessView];
    [self makeButtonsPassive];
}

- (void) manualSyncFinalized {
    IGLog(@"ContactSync sync successfully finished");
    [self hideProcessView];
    [self makeButtonsActive];
    
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
    return tableViewRowCount;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewRowHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableViewHeaderHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    headerView.backgroundColor = [Util UIColorForHexColor:@"f4f5f8"];
    
    CustomLabel *headerLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ContactLastSyncDetailTitle", @"") withAlignment:NSTextAlignmentCenter];
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
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailUpdateTitle", @"") withVal:syncVal isBold:NO];
    } else if(indexPath.row == 2) {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult serverNewCount] : [APPDELEGATE.session.syncResult clientNewCount];
        //        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailNewTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientNewCount] withServerVal:[APPDELEGATE.session.syncResult serverNewCount]];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailNewTitle", @"") withVal:syncVal isBold:NO];
    } else if(indexPath.row == 3) {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult serverDeleteCount] : [APPDELEGATE.session.syncResult clientDeleteCount];
        //        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"") withClientVal:[APPDELEGATE.session.syncResult clientDeleteCount] withServerVal:[APPDELEGATE.session.syncResult serverDeleteCount]];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"") withVal:syncVal isBold:NO];
    } else {
        int syncVal = [APPDELEGATE.session.syncResult syncType] == ContactSyncTypeBackup ? [APPDELEGATE.session.syncResult totalContactOnServer] : [APPDELEGATE.session.syncResult totalContactOnClient];
        return [[ContactSyncResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:NSLocalizedString(@"ContactLastSyncDetailTotalTitle", @"") withVal:syncVal isBold:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([ContactSyncSDK isRunning]) {
        [self showProcessView];
        [self makeButtonsPassive];
    } else {
        [self makeButtonsActive];
    }
}

- (void)showProcessView {
    BaseViewController *base = APPDELEGATE.base;
    
    NSString *processMessage, *successMessage, *failMessage;
    if (APPDELEGATE.session.syncType == ContactSyncTypeBackup) {
        processMessage = NSLocalizedString(@"ContactSyncBackupProgresssMessage", "");
        successMessage = NSLocalizedString(@"ContactSyncBackupSuccessMessage", "");
        failMessage = NSLocalizedString(@"ContactSyncBackupFailMessage", "");
    } else {
        processMessage = NSLocalizedString(@"ContactSyncRestoreProgresssMessage", "");
        successMessage = NSLocalizedString(@"ContactSyncRestoreSuccessMessage", "");
        failMessage = NSLocalizedString(@"ContactSyncRestoreFailMessage", "");
    }
    
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, base.view.frame.size.height - 60, base.view.frame.size.width, 60)
                                        withProcessMessage:processMessage
                                          withFinalMessage:successMessage
                                           withFailMessage:failMessage];
    processView.delegate = self;
    
    [base.view addSubview:processView];
    [processView startLoading];
}

- (void)hideProcessView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [processView dismissWithSuccessMessage];
        processView = nil;
    });
}

- (void) processFooterShouldDismissWithButtonKey:(NSString *) postButtonKeyVal {
//    [self hideProcessView];
}

#pragma mark - RequestTokenDao

- (void) triggerNewToken {
    IGLog(@"ContactSync at triggerNewToken");
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
        IGLog(@"ContactSync at triggerNewToken kReachableViaWiFi || kReachableViaWWAN");
        if([CacheUtil readRememberMeToken] != nil) {
            IGLog(@"ContactSync at triggerNewToken readRememberMeToken not null");
            _tokenDao = [[RequestTokenDao alloc] init];
            _tokenDao.delegate = self;
            _tokenDao.successMethod = @selector(tokenRevisitedSuccessCallback);
            _tokenDao.failMethod = @selector(tokenRevisitedFailCallback:);
            [_tokenDao requestTokenByRememberMe];
        } else {
            if(networkStatus == kReachableViaWiFi) {
                IGLog(@"ContactSync at triggerNewToken readRememberMeToken null - kReachableViaWiFi");
                //            [self shouldReturnFailWithMessage:LOGIN_REQ_ERROR_MESSAGE];
                //                NSLog(@"Login Required Triggered within triggerNewToken instead of fail method: %@", NSStringFromSelector(failMethod));
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_REQ_NOTIFICATION object:nil userInfo:nil];
            } else {
                IGLog(@"ContactSync at triggerNewToken readRememberMeToken null - not kReachableViaWiFi -  calling radiusDao");
                _radiusDao = [[RadiusDao alloc] init];
                _radiusDao.delegate = self;
                _radiusDao.successMethod = @selector(tokenRevisitedSuccessCallback);
                _radiusDao.failMethod = @selector(tokenRevisitedFailCallback:);
                [_radiusDao requestRadiusLogin];
            }
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
        [self hideProcessView];
        [self makeButtonsActive];
    }
}

- (void) tokenRevisitedSuccessCallback {
    IGLog(@"ContactSync token request successed");
    [SyncSettings shared].token = APPDELEGATE.session.authToken;
    [ContactSyncSDK doSync:syncMode];
}

- (void) tokenRevisitedFailCallback:(NSString *) errorMessage {
    IGLog(@"ContactSync token request failed");
    [self showErrorAlertWithMessage:NSLocalizedString(_errMessage, @"")];
    [self hideProcessView];
    [self makeButtonsActive];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.view.superview == nil) {
            [UIView animateWithDuration:0.3 animations:^{
                processView.hidden = YES;
            }];
        }
    });
    
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

- (void)makeButtonsPassive {
    backupButton.enabled = NO;
    restoreButton.enabled = NO;
    backupButton.alpha = 0.5f;
    restoreButton.alpha = 0.5f;
}

- (void)makeButtonsActive {
    backupButton.enabled = YES;
    restoreButton.enabled = YES;
    backupButton.alpha = 1.0f;
    restoreButton.alpha = 1.0f;
}

@end

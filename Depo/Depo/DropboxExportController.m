//
//  DropboxExportController.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxExportController.h"
#import "RevisitedStorageController.h"
#import "CustomButton.h"
#import "DropboxExportResult.h"
#import "Util.h"
#import "DropboxStatusCell.h"
#import "AppUtil.h"
#import "AppDelegate.h"

@interface DropboxExportController () {
    CustomButton *exportButton;
    DropboxExportResult *recentResult;
    DBRestClient *accountInfoClient;
}
@end

@implementation DropboxExportController

@synthesize mainStatusView;
@synthesize circleView;
@synthesize percentLabel;
@synthesize statusChart;
@synthesize statusList;
@synthesize statusColors;
@synthesize connectDao;
@synthesize startDao;
@synthesize statusDao;
@synthesize statusDaoForStart;
@synthesize resultTable;
@synthesize tokenDao;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"ExportFromDropbox", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"f5f5f5"];

        float buttonSize = 280;
        
        connectDao = [[DropboxConnectDao alloc] init];
        connectDao.delegate = self;
        connectDao.successMethod = @selector(connectSuccessCallback);
        connectDao.failMethod = @selector(connectFailCallback:);
        
        startDao = [[DropboxStartDao alloc] init];
        startDao.delegate = self;
        startDao.successMethod = @selector(startSuccessCallback);
        startDao.failMethod = @selector(startFailCallback:);
        
        statusDaoForStart = [[DropboxStatusDao alloc] init];
        statusDaoForStart.delegate = self;
        statusDaoForStart.successMethod = @selector(statusForStartSuccessCallback:);
        statusDaoForStart.failMethod = @selector(statusFailCallback:);

        statusDao = [[DropboxStatusDao alloc] init];
        statusDao.delegate = self;
        statusDao.successMethod = @selector(statusSuccessCallback:);
        statusDao.failMethod = @selector(statusFailCallback:);

        tokenDao = [[DropboxTokenDao alloc] init];
        tokenDao.delegate = self;
        tokenDao.successMethod = @selector(tokenSuccessCallback:);
        tokenDao.failMethod = @selector(tokenFailCallback:);
        
        UIImage *iconImg = [UIImage imageNamed:@"img_dbtasi.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - iconImg.size.width)/2, 30, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self.view addSubview:iconView];

        CustomLabel *infoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(30, iconView.frame.origin.y + iconView.frame.size.height + 20, self.view.frame.size.width - 60, 60) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"DropboxSubInfo", @"") withAlignment:NSTextAlignmentCenter numberOfLines:3];
        [self.view addSubview:infoTitle];

        exportButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize)/2, infoTitle.frame.origin.y + infoTitle.frame.size.height + 20, buttonSize, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"DropboxExport", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [exportButton addTarget:self action:@selector(triggerExport) forControlEvents:UIControlEventTouchUpInside];
        exportButton.enabled = NO;
        exportButton.isAccessibilityElement = YES;
        exportButton.accessibilityIdentifier = @"exportButtonDropboxExport";
        [self.view addSubview:exportButton];

        resultTable = [[UITableView alloc] initWithFrame:CGRectMake(20, exportButton.frame.origin.y + exportButton.frame.size.height + 10, self.view.frame.size.width - 40, 90) style:UITableViewStylePlain];
        resultTable.backgroundColor = [UIColor clearColor];
        resultTable.backgroundView = nil;
        resultTable.delegate = self;
        resultTable.dataSource = self;
        resultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        resultTable.bounces = NO;
        resultTable.isAccessibilityElement = YES;
        resultTable.accessibilityIdentifier = @"resultTableDropboxExport";
        [self.view addSubview:resultTable];

        mainStatusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        mainStatusView.hidden = YES;
        mainStatusView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:mainStatusView];
        
        UIImageView *statusBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainStatusView.frame.size.width, mainStatusView.frame.size.height)];
        statusBgImgView.image = [UIImage imageNamed:@"bg_fullimg.png"];
        [mainStatusView addSubview:statusBgImgView];
        
        UIImage *statusBgImg = [UIImage imageNamed:@"bg_cloud_big.png"];
        float statusInfoWidth = mainStatusView.frame.size.width - 80;
        float statusInfoHeight = statusInfoWidth * statusBgImg.size.height/statusBgImg.size.width;
        UIImageView *statusInfoView = [[UIImageView alloc] initWithFrame:CGRectMake((mainStatusView.frame.size.width - statusInfoWidth)/2, (mainStatusView.frame.size.height - statusInfoHeight)/2 - 50, statusInfoWidth, statusInfoHeight)];
        statusInfoView.image = statusBgImg;
        [mainStatusView addSubview:statusInfoView];

        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((statusInfoView.frame.size.width - 100)/2, (statusInfoView.frame.size.height - 40)/2, 100, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:34] withColor:[Util UIColorForHexColor:@"555555"] withText:@""];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [statusInfoView addSubview:percentLabel];

        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, percentLabel.frame.origin.y + percentLabel.frame.size.height + 5, statusInfoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ExportingFiles", @"") withAlignment:NSTextAlignmentCenter];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [statusInfoView addSubview:subInfoLabel];

        /*
        statusChart = [[XYPieChart alloc] initWithFrame:CGRectMake((mainStatusView.frame.size.width - 120)/2, 0, 120, 120)];
        statusChart.dataSource = self;
        statusChart.startPieAngle = -M_PI_2;
        statusChart.animationSpeed = 0.01;
        statusChart.showLabel = NO;
        statusChart.showPercentage = NO;
        statusChart.pieBackgroundColor = [UIColor whiteColor];
        //        statusChart.pieCenter = CGPointMake(200, 200);
        statusChart.userInteractionEnabled = NO;
        statusChart.labelShadowColor = [UIColor blackColor];
        [mainStatusView addSubview:statusChart];
        
        circleView = [[UIView alloc] initWithFrame:CGRectMake((mainStatusView.frame.size.width - 90)/2, 15, 90, 90)];
        circleView.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        circleView.layer.cornerRadius = 45;
        [mainStatusView addSubview:circleView];
        
        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((mainStatusView.frame.size.width - 70)/2, 45, 70, 30) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:25] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:@""];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [mainStatusView addSubview:percentLabel];

        CustomLabel *tableTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(20, statusChart.frame.origin.y + statusChart.frame.size.height + 20, mainStatusView.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"DropboxExportStatus", @"")];
        [mainStatusView addSubview:tableTitle];
         */
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxDidLogin) name:DROPBOX_LINK_SUCCESS_KEY object:nil];
 
        [self scheduleStatusQuery];
        
    }
    return self;
}

- (void) dropboxDidLogin {
    accountInfoClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    accountInfoClient.delegate = self;
    [accountInfoClient loadAccountInfo];
    [self showLoading];
}

- (void) triggerExport {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        accountInfoClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        accountInfoClient.delegate = self;
        [accountInfoClient loadAccountInfo];
        [self showLoading];
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

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return [self.statusList count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.statusList objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.statusColors objectAtIndex:(index % self.statusColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
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

- (void) connectSuccessCallback {
    //    [startDao requestStartDropbox];
    [statusDaoForStart requestDropboxStatus];
}

- (void) connectFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) startSuccessCallback {
    [self hideLoading];
    [self performSelector:@selector(scheduleStatusQuery) withObject:nil afterDelay:2.0f];
}

- (void) startFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) statusSuccessCallback:(DropboxExportResult *) status {
    [self hideLoading];
    if(status.connected) {
        recentResult = status;
        
        percentLabel.text = [NSString stringWithFormat:@"%%%d", (int)status.progress];
        self.statusList = [NSMutableArray arrayWithCapacity:2];
        [statusList addObject:[NSNumber numberWithFloat:status.progress]];
        [statusList addObject:[NSNumber numberWithFloat:(100 - status.progress)]];
        
        self.statusColors =[NSArray arrayWithObjects:
                            [Util UIColorForHexColor:@"3fb0e8"],
                            [Util UIColorForHexColor:@"FFFFFF"], nil];
        
        [statusChart reloadData];
        
        if(status.status == DropboxExportStatusFinished || status.status == DropboxExportStatusFailed || status.status == DropboxExportStatusCancelled) {
            exportButton.enabled = YES;
        } else {
            exportButton.enabled = NO;
        }
        
        if(status.status == DropboxExportStatusRunning || status.status == DropboxExportStatusPending || status.status == DropboxExportStatusScheduled) {
            [self performSelector:@selector(scheduleStatusQuery) withObject:nil afterDelay:2.0f];
            mainStatusView.hidden = NO;
        } else {
            mainStatusView.hidden = YES;
        }
        resultTable.hidden = NO;
        [resultTable reloadData];
    } else {
        resultTable.hidden = YES;
        exportButton.enabled = YES;
    }
}

- (void) statusForStartSuccessCallback:(DropboxExportResult *) status {
    [self hideLoading];
    if (status.isQuotaValid) {
        [startDao requestStartDropbox];
    } else {
        CustomConfirmView *confirmView = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"")  withApproveTitle:NSLocalizedString(@"OK", @"")  withMessage:NSLocalizedString(@"DropboxInvalidQuotaMessage", @"") withModalType:ModalTypeApprove];
        confirmView.delegate = self;
        [APPDELEGATE showCustomConfirm:confirmView];
    }
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    [self.navigationController pushViewController:storageController animated:YES];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
    
}

- (void) scheduleStatusQuery {
    [statusDao requestDropboxStatus];
    [self showLoading];
}

- (void) statusFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    exportButton.enabled = YES;
    if([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
    }
}

- (void) tokenSuccessCallback:(NSString *) newToken {
    [connectDao requestConnectDropboxWithToken:newToken];
}

- (void) tokenFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
    [self hideLoading];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(recentResult) {
        return 3;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"DROPBOX_STATUS_CELL"];
    NSString *cellText;
    if(indexPath.row == 0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy"];
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxLastExportDate", @""),recentResult.date ? [dateFormat stringFromDate: recentResult.date] : @"-"];
    } else if(indexPath.row == 1) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxSuccessResult", @""), recentResult.successCount];
    } else if(indexPath.row == 2) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxFailedResult", @""), recentResult.failedCount];
//    } else {
//        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxSkippedResult", @""), recentResult.skippedCount];
    }
    
    DropboxStatusCell *cell = [[DropboxStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:cellText];
    return cell;
}

- (void) restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
    NSLog(@"At loadedAccountInfo: %@", info);
    if(info) {
        MPOAuthCredentialConcreteStore *credentials = [[DBSession sharedSession] credentialStoreForUserId:info.userId];
        if(credentials.accessToken){
            [tokenDao requestTokenWithCurrentToken:credentials.accessToken withConsumerKey:credentials.consumerKey withAppSecret:@"umjclqg3juoyihd" withAuthTokenSecret:credentials.accessTokenSecret];
            return;
        }
    }
    [self showErrorAlertWithMessage:NSLocalizedString(@"DropboxAccessError", @"")];
    [self hideLoading];
}

- (void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error {
    if(error.code == 401) { // Uygulama izninin Dropbox'tan silindigi durumda alinan 401 icin eklendi.
        if([[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] unlinkAll];
            [self triggerExport];
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"DropboxAccessError", @"")];
    }
    [self hideLoading];
}

- (NSArray *)getTokensFromSyncAPI {
    NSString *keychainPrefix = [[NSBundle mainBundle] bundleIdentifier];
    NSString *keychainId = [NSString stringWithFormat:@"%@.%@", keychainPrefix, @"dropbox-sync.auth"];
    NSDictionary *keychainDict = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                   (__bridge id)kSecAttrService: keychainId,
                                   (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                   (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
                                   (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue};
    
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainDict,
                                          (CFTypeRef *)&result);
    NSDictionary *attrDict = (__bridge_transfer NSDictionary *)result;
    NSData *foundValue = [attrDict objectForKey:(__bridge id)kSecValueData];
    NSMutableArray *credentials = [[NSMutableArray alloc] init];
    
    if (status == noErr && foundValue) {
        NSDictionary *savedCreds = [NSKeyedUnarchiver unarchiveObjectWithData:foundValue];
//        NSArray *credsForApp = [[savedCreds objectForKey:@"accounts"] objectForKey:@"zeddgylajxc1op8"];
         NSArray *credsForApp = [[savedCreds objectForKey:@"accounts"] objectForKey:@"422fptod5dlxrn8"]; 
        for (NSDictionary *credsForUser in credsForApp) {
            NSDictionary *token = @{
                                    @"userId": [credsForUser objectForKey:@"userId"],
                                    @"token": [credsForUser objectForKey:@"token"],
                                    @"tokenSecret": [credsForUser objectForKey:@"tokenSecret"]
                                    };
            [credentials addObject:token];
        }
    }
    return credentials;
}

- (void)cancelRequests {
    [statusDao cancelRequest];
    statusDao = nil;
    
    [connectDao cancelRequest];
    connectDao = nil;
    
    [startDao cancelRequest];
    startDao = nil;

    [tokenDao cancelRequest];
    tokenDao = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end

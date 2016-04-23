//
//  DropboxExportController.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxExportController.h"
#import "CustomButton.h"
#import "DropboxExportResult.h"
#import "Util.h"
#import "DropboxStatusCell.h"

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

        statusDao = [[DropboxStatusDao alloc] init];
        statusDao.delegate = self;
        statusDao.successMethod = @selector(statusSuccessCallback:);
        statusDao.failMethod = @selector(statusFailCallback:);

        tokenDao = [[DropboxTokenDao alloc] init];
        
        exportButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize)/2, 50, buttonSize, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"Export", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor]];
        [exportButton addTarget:self action:@selector(triggerExport) forControlEvents:UIControlEventTouchUpInside];
        exportButton.enabled = NO;
        [self.view addSubview:exportButton];

        mainStatusView = [[UIView alloc] initWithFrame:CGRectMake(0, exportButton.frame.origin.y + exportButton.frame.size.height + 5, self.view.frame.size.width, self.view.frame.size.height - exportButton.frame.origin.y - exportButton.frame.size.height - 5)];
        mainStatusView.hidden = YES;
        [self.view addSubview:mainStatusView];
        
        statusChart = [[XYPieChart alloc] initWithFrame:CGRectMake(mainStatusView.frame.size.width - 180, 0, 120, 120)];
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
        
        UIImage *circleImg = [UIImage imageNamed:@"yuvarlakbulut.png"];
        circleView = [[UIImageView alloc] initWithFrame:CGRectMake(mainStatusView.frame.size.width - 165, 15, 90, 90)];
        circleView.image = circleImg;
        [mainStatusView addSubview:circleView];
        
        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, 45, 70, 30) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:25] withColor:[Util UIColorForHexColor:@"555555"] withText:@""];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [mainStatusView addSubview:percentLabel];

        CustomLabel *tableTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(20, statusChart.frame.origin.y + statusChart.frame.size.height + 20, mainStatusView.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"DropboxExportStatus", @"")];
        [mainStatusView addSubview:tableTitle];

        resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tableTitle.frame.origin.y + tableTitle.frame.size.height + 10, mainStatusView.frame.size.width, 120) style:UITableViewStylePlain];
        resultTable.backgroundColor = [UIColor clearColor];
        resultTable.backgroundView = nil;
        resultTable.delegate = self;
        resultTable.dataSource = self;
        resultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [mainStatusView addSubview:resultTable];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxDidLogin) name:DROPBOX_LINK_SUCCESS_KEY object:nil];
 
        [statusDao requestDropboxStatus];
        [self showLoading];
        
        //TODO sil
//        [self performSelector:@selector(temp) withObject:nil afterDelay:4.0f];
    }
    return self;
}

- (void) temp {
    DropboxExportResult *status = [[DropboxExportResult alloc] init];
    status.connected = YES;
    status.successCount = 10;
    status.failedCount = 4;
    status.skippedCount = 2;
    [self statusSuccessCallback:status];
}

- (void) dropboxDidLogin {
    accountInfoClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    accountInfoClient.delegate = self;
    [accountInfoClient loadAccountInfo];
}

- (void) triggerExport {
    [self showLoading];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    } else {
        accountInfoClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        accountInfoClient.delegate = self;
        [accountInfoClient loadAccountInfo];
//        [connectDao requestConnectDropboxWithToken:nil];
//        [self showLoading];
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
    [startDao requestStartDropbox];
}

- (void) connectFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) startSuccessCallback {
    [self hideLoading];
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
        
        if(status.status == DropboxExportStatusFinished || status.status == DropboxExportStatusFailed) {
            exportButton.enabled = YES;
        } else {
            exportButton.enabled = NO;
        }
        
        if(status.status == DropboxExportStatusRunning) {
            [self performSelector:@selector(scheduleStatusQuery) withObject:nil afterDelay:2.0f];
        }
        mainStatusView.hidden = NO;
        [resultTable reloadData];
    } else {
        mainStatusView.hidden = YES;
        exportButton.enabled = YES;
    }
}

- (void) scheduleStatusQuery {
    [statusDao requestDropboxStatus];
}

- (void) statusFailCallback:(NSString *) errorMessage {
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
    return 40;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"DROPBOX_STATUS_CELL"];
    NSString *cellText;
    if(indexPath.row == 0) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxSuccessResult", @""), recentResult.successCount];
    } else if(indexPath.row == 1) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxFailedResult", @""), recentResult.failedCount];
    } else {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxSkippedResult", @""), recentResult.skippedCount];
    }
    DropboxStatusCell *cell = [[DropboxStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:cellText];
    return cell;
}

- (void) restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
    NSLog(@"At loadedAccountInfo: %@", info);
    if(info) {
        MPOAuthCredentialConcreteStore *credentials = [[DBSession sharedSession] credentialStoreForUserId:info.userId];
        if(credentials.accessToken){
            [connectDao requestConnectDropboxWithToken:credentials.accessToken];
            return;
        }
    }
    [self showErrorAlertWithMessage:NSLocalizedString(@"DropboxAccessError", @"")];
}

- (void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error {
    [self showErrorAlertWithMessage:NSLocalizedString(@"DropboxAccessError", @"")];
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
        NSArray *credsForApp = [[savedCreds objectForKey:@"accounts"] objectForKey:@"mydrrngzkvnljgs"];
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

@end

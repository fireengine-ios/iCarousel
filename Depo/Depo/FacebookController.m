//
//  FacebookController.m
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FacebookController.h"
#import "SoclaiStatusCell.h"

@interface FacebookController ()

@end

@implementation FacebookController

@synthesize statusDao;
@synthesize startDao;

- (id) init {
    if(self = [super initWithImageName:@"img_dbtasi.png.png" withMessage:NSLocalizedString(@"FBSubInfo", @"")]) {
        
        statusDao = [[FBStatusDao alloc] init];
        statusDao.delegate = self;
        statusDao.successMethod = @selector(statusSuccessCallback:);
        statusDao.failMethod = @selector(statusFailCallback:);
        
        startDao = [[FBStartDao alloc] init];
        startDao.delegate = self;
        startDao.successMethod = @selector(startSuccessCallback);
        startDao.failMethod = @selector(startFailCallback:);
        
        [self scheduleStatusQuery];
    }
    return self;
}

- (void) triggerExport {
    [startDao requestFBStart];
    [self showLoading];
}

- (void) scheduleStatusQuery {
    [statusDao requestFBStatus];
    [self showLoading];
}

- (void) statusSuccessCallback:(SocialExportResult *) status {
    [self hideLoading];
    if(status.connected) {
        self.recentStatus = status;
        
        self.percentLabel.text = [NSString stringWithFormat:@"%%%d", (int)status.progress];
        if(status.status == SocialExportStatusFinished || status.status == SocialExportStatusFailed || status.status == SocialExportStatusCancelled) {
            self.exportButton.enabled = YES;
        } else {
            self.exportButton.enabled = NO;
        }
        
        if(status.status == SocialExportStatusRunning || status.status == SocialExportStatusPending || status.status == SocialExportStatusScheduled) {
            [self performSelector:@selector(scheduleStatusQuery) withObject:nil afterDelay:2.0f];
            self.mainStatusView.hidden = NO;
        } else {
            self.mainStatusView.hidden = YES;
        }
        self.resultTable.hidden = NO;
        [self.resultTable reloadData];
    } else {
        self.resultTable.hidden = YES;
        self.exportButton.enabled = YES;
    }
}

- (void) statusFailCallback:(NSString *) errorMessage {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.recentStatus) {
        return 3;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"SOCIAL_STATUS_CELL"];
    NSString *cellText;
    if(indexPath.row == 0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy"];
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxLastExportDate", @""),self.recentStatus.lastDate ? [dateFormat stringFromDate: self.recentStatus.lastDate] : @"-"];
    } else if(indexPath.row == 1) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxSuccessResult", @""), self.recentStatus.successCount];
    } else if(indexPath.row == 2) {
        cellText = [NSString stringWithFormat:NSLocalizedString(@"DropboxFailedResult", @""), self.recentStatus.failedCount];
    }
    
    SoclaiStatusCell *cell = [[SoclaiStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:cellText];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelRequests {
    [statusDao cancelRequest];
    statusDao = nil;
    
    [startDao cancelRequest];
    startDao = nil;
}

@end

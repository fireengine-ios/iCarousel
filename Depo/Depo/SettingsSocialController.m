//
//  SettingsSocialController.m
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SettingsSocialController.h"
#import "Util.h"
#import "TitleCell.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FacebookController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SettingsSocialController ()

@end

@implementation SettingsSocialController

@synthesize mainTable;
@synthesize fbPermissionDao;
@synthesize fbConnectDao;
@synthesize fbStatusDao;
@synthesize fbStartDao;
@synthesize fbStopDao;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SocialMediaTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];

        fbPermissionDao = [[FBPermissionDao alloc] init];
        fbPermissionDao.delegate = self;
        fbPermissionDao.successMethod = @selector(fbPermissionSuccessCallback:);
        fbPermissionDao.failMethod = @selector(fbPermissionFailCallback:);
        
        fbConnectDao = [[FBConnectDao alloc] init];
        fbConnectDao.delegate = self;
        fbConnectDao.successMethod = @selector(fbConnectSuccessCallback);
        fbConnectDao.failMethod = @selector(fbConnectFailCallback:);
        
        fbStatusDao = [[FBStatusDao alloc] init];
        fbStatusDao.delegate = self;
        fbStatusDao.successMethod = @selector(fbStatusSuccessCallback:);
        fbStatusDao.failMethod = @selector(fbStatusFailCallback:);

        fbStartDao = [[FBStartDao alloc] init];
        fbStartDao.delegate = self;
        fbStartDao.successMethod = @selector(fbStartSuccessCallback);
        fbStartDao.failMethod = @selector(fbStartFailCallback:);

        fbStopDao = [[FBStopDao alloc] init];
        fbStopDao.delegate = self;
        fbStopDao.successMethod = @selector(fbStopSuccessCallback);
        fbStopDao.failMethod = @selector(fbStopFailCallback:);

        mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        mainTable.bounces = NO;
        mainTable.delegate = self;
        mainTable.dataSource = self;
        mainTable.backgroundColor = [UIColor clearColor];
        mainTable.backgroundView = nil;
        mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mainTable];
    }
    return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"SettingsSharedCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        TitleWithSwitchCell *cell = [[TitleWithSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withIcon:@"icon_fb_aktar.png" withTitle:NSLocalizedString(@"FacebookExportTitle", @"") withSwitchKey:FB_AUTO_SYNC_SWITCH_KEY withIndex:(int)indexPath.row];
        cell.delegate = self;
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) titleWithSwitchValueChanged:(BOOL)isOn forKey:(NSString *)switchKeyRef {
    if([switchKeyRef isEqualToString:FB_AUTO_SYNC_SWITCH_KEY]) {
        if(isOn != [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyRef]) {
            if(isOn) {
                [self triggerFacebookStart];
            } else {
                [self triggerFacebookStop];
            }
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:switchKeyRef];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void) triggerFacebookStart {
    NSLog(@"At triggerFacebookStart");
    [fbStatusDao requestFBStatus];
    [self showLoading];
}

- (void) triggerFacebookStop {
    NSLog(@"At triggerFacebookStop");
    [fbStopDao requestFBStop];
    [self showLoading];
}

- (void) triggerFacebookLogin {
    [fbPermissionDao requestFbPermissionTypes];
    [self showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fbPermissionSuccessCallback:(NSDictionary *) permissions {
    IGLog(@"FB Permission succeeded");
    [self hideLoading];
    //TODO servisten gelende publish_actions vardi, o da hata veriyordu. Ayrıca publish için ikinci bir request yapmak gerekiyor API'ye
//    [self triggerFBLoginWithPermissions:[NSArray arrayWithObjects:@"public_profile", @"user_photos", @"user_videos", @"user_birthday", @"user_events", nil]];
    [self triggerFBLoginWithPermissions:permissions];
}

- (void) fbPermissionFailCallback:(NSString *) errorMessage {
    IGLog(@"FB Permission failed");
    [self hideLoading];
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"user_photos", @"user_videos", @"user_birthday", nil];
    [self triggerFBLoginWithPermissions:permissions];
}

- (void) fbConnectSuccessCallback {
    IGLog(@"FB Connect succeeded");
    [fbStartDao requestFBStart];
}

- (void) fbConnectFailCallback:(NSString *) errorMessage {
    IGLog(@"FB Connect failed");
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
}

- (void) triggerFBLoginWithPermissions:(NSDictionary *) permissions {
    [self hideLoading];
    
    NSArray *readPermissions = [permissions objectForKey:@"read"];

    FBSDKLoginManager *fbLoginButton = [[FBSDKLoginManager alloc] init];
    fbLoginButton.loginBehavior = FBSDKLoginBehaviorWeb;
    [fbLoginButton logInWithReadPermissions:readPermissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Process error1");
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showErrorAlertWithMessage:NSLocalizedString(@"FBConnectError", @"")];
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
            });
        } else if (result.isCancelled) {
            NSLog(@"Cancelled1");
            dispatch_async(dispatch_get_main_queue(), ^(){
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
            });
        } else {
            NSLog(@"Read permission Logged in");
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSLog(@"Access token: %@", [[FBSDKAccessToken currentAccessToken] tokenString]);
                [fbConnectDao requestFbConnectWithToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
                [self showLoading];
            });
        }
    }];
}

- (void) triggerNextPermissionStep:(NSArray *) publishPermissions {
    FBSDKLoginManager *fbNextLoginButton = [[FBSDKLoginManager alloc] init];
    [fbNextLoginButton logInWithPublishPermissions:publishPermissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult *nextResult, NSError *nextError) {
        if (nextError) {
            NSLog(@"Process error2");
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showErrorAlertWithMessage:NSLocalizedString(@"FBConnectError", @"")];
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
            });
        } else if (nextResult.isCancelled) {
            NSLog(@"Cancelled2");
            dispatch_async(dispatch_get_main_queue(), ^(){
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
            });
        } else {
            NSLog(@"Publish permission Logged in");
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSLog(@"Access token: %@", [[FBSDKAccessToken currentAccessToken] tokenString]);
                [fbConnectDao requestFbConnectWithToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
                [self showLoading];
            });
        }
    }];
}

- (void) fbStatusSuccessCallback:(SocialExportResult *) fbStatus {
    if(fbStatus && fbStatus.connected) {
        IGLog(@"FB Status: connected");
        [fbStartDao requestFBStart];
    } else {
        IGLog(@"FB Status: not connected");
        [fbPermissionDao requestFbPermissionTypes];
    }
}

- (void) fbStatusFailCallback:(NSString *) errorMessage {
    IGLog(@"FB Status service failed. Calling permission dao");
    [fbPermissionDao requestFbPermissionTypes];
}

- (void) fbStartSuccessCallback {
    IGLog(@"FB Start succeed");
    [self hideLoading];
}

- (void) fbStartFailCallback:(NSString *) errorMessage {
    IGLog(@"FB Start failed");
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil userInfo:nil];
}

- (void) fbStopSuccessCallback {
    IGLog(@"FB Stop succeeded");
    [self hideLoading];
}

- (void) fbStopFailCallback:(NSString *) errorMessage {
    IGLog(@"FB Stop failed");
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) cancelRequests {
    [fbPermissionDao cancelRequest];
    fbPermissionDao = nil;

    [fbConnectDao cancelRequest];
    fbConnectDao = nil;

    [fbStatusDao cancelRequest];
    fbStatusDao = nil;

    [fbStartDao cancelRequest];
    fbStartDao = nil;

    [fbStopDao cancelRequest];
    fbStopDao = nil;
}

@end

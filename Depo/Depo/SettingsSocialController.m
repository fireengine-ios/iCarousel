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
    double cellHeight = 69;
    
    if(indexPath.row == 0) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"FacebookExportTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_fb_aktar.png" hasSeparator:YES isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"InstagramExportTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_dbtasi" hasSeparator:YES isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 0:
            [self triggerFacebookLogin];
            break;
        case 1:
            break;
        default:
            break;
    }
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

- (void) fbPermissionSuccessCallback:(NSArray *) permissions {
    [self hideLoading];
    [self triggerFBLoginWithPermissions:permissions];
}

- (void) fbPermissionFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"user_photos", @"user_videos", @"user_birthday", nil];
    [self triggerFBLoginWithPermissions:permissions];
}

- (void) fbConnectSuccessCallback {
    [self hideLoading];
    FacebookController *controller = [[FacebookController alloc] init];
    [self.nav pushViewController:controller animated:YES];
}

- (void) fbConnectFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) triggerFBLoginWithPermissions:(NSArray *) permissions {
    FBSDKLoginManager *fbLoginButton = [[FBSDKLoginManager alloc] init];
    [fbLoginButton logInWithReadPermissions:permissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Process error");
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self showErrorAlertWithMessage:NSLocalizedString(@"FBConnectError", @"")];
            });
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Logged in");
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSLog(@"Access token: %@", [[FBSDKAccessToken currentAccessToken] tokenString]);
                [fbConnectDao requestFbConnectWithToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
                [self showLoading];
            });
        }
    }];
}

@end

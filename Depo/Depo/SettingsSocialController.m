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

@interface SettingsSocialController ()

@end

@implementation SettingsSocialController

@synthesize mainTable;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SocialMediaTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];

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
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"FacebookExportTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_dbtasi" hasSeparator:YES isLink:YES linkText:@"" cellHeight:cellHeight];
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
    FBSDKLoginManager *fbLoginButton = [[FBSDKLoginManager alloc] init];
    [fbLoginButton logInWithReadPermissions: @[@"public_profile", @"user_photos", @"user_videos"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
         }
     }];
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

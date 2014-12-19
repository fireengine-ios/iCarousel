//
//  SettingsNotificationsController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsNotificationsController.h"

@interface SettingsNotificationsController ()

@end

@implementation SettingsNotificationsController

- (id)init
{
    infoText = NSLocalizedString(@"NotificationsInfo", @"");
    infoTextHeight = [Util calculateHeightForText:infoText forWidth:290 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Notifications", @"");
        currentNotificationSetting = [CacheUtil readCachedSettingNotification];
        oldNotificationSetting = currentNotificationSetting;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (currentNotificationSetting != oldNotificationSetting)
        [CacheUtil writeCachedSettingNotification:currentNotificationSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return 31;
    else if(indexPath.row == 6)
        return infoTextHeight + 48;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Anytime", @"") checkStatus:(currentNotificationSetting == NotificationOptionAnytime)];
        return cell;
    } else if(indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"OnceADay", @"") checkStatus:(currentNotificationSetting == NotificationOptionOnceADay)];
        return cell;
    } else if(indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"OnceAWeek", @"") checkStatus:(currentNotificationSetting == NotificationOptionOnceAWeek)];
        return cell;
    } else if(indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"OnceAMonth", @"") checkStatus:(currentNotificationSetting == NotificationOptionOnceAMonth)];
        return cell;
    } else if(indexPath.row == 5) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Never", @"") checkStatus:(currentNotificationSetting == NotificationOptionNever)];
        return cell;
    } else if(indexPath.row == 6) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoText contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 1:
            [self setAnytime];
            break;
        case 2:
            [self setOnceADay];
            break;
        case 3:
            [self setOnceAWeek];
            break;
        case 4:
            [self setOnceAMonth];
            break;
        case 5:
            [self setNever];
            break;
        default:
            break;
    }
}

- (void) setAnytime {
    currentNotificationSetting = NotificationOptionAnytime;
    [self drawPageContentTable];
}

- (void) setOnceADay {
    currentNotificationSetting = NotificationOptionOnceADay;
    [self drawPageContentTable];
}

- (void) setOnceAWeek {
    currentNotificationSetting = NotificationOptionOnceAWeek;
    [self drawPageContentTable];
}

- (void) setOnceAMonth {
    currentNotificationSetting = NotificationOptionOnceAMonth;
    [self drawPageContentTable];
}

- (void) setNever {
    currentNotificationSetting = NotificationOptionNever;
    [self drawPageContentTable];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

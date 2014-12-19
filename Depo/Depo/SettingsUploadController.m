//
//  SettingsUploadController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsUploadController.h"
#import "SettingsPhotosVideosController.h"
#import "SettingsMusicController.h"
#import "SettingsDocumentsController.h"
#import "SettingsContactsController.h"

@interface SettingsUploadController ()

@end

@implementation SettingsUploadController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Upload&Syncing", @"");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    currentSyncPhotosVideosSetting = [CacheUtil readCachedSettingSyncPhotosVideos];
    currentSyncMusicSetting = [CacheUtil readCachedSettingSyncMusic];
    currentSyncDocumentsSetting = [CacheUtil readCachedSettingSyncDocuments];
    currentSyncContactsSetting = [CacheUtil readCachedSettingSyncContacts];
    currentConnectionSetting = [CacheUtil readCachedSettingSyncingConnectionType];
    oldConnectionSetting = currentConnectionSetting;
    currentDataRoamingSetting = [CacheUtil readCachedSettingDataRaming];
    oldDataRoamingSetting = currentDataRoamingSetting;
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (currentConnectionSetting != oldConnectionSetting)
        [CacheUtil writeCachedSettingSyncingConnectionType:currentConnectionSetting];
    if (currentDataRoamingSetting != oldDataRoamingSetting)
        [CacheUtil writeCachedSettingDataRoaming:currentDataRoamingSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 || indexPath.row == 8)
        return 31;
    else if(indexPath.row == 6 || indexPath.row == 7)
        return 44;
    else if(indexPath.row == 9)
        return 69;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Photos&Videos", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncPhotosVideosSetting] cellHeight:54];
        return cell;
    } else if(indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Music", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncMusicSetting] cellHeight:54];
        return cell;
    } else if(indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Documents", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncDocumentsSetting] cellHeight:54];
        return cell;
    } else if(indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Contacts", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncContactsSetting] cellHeight:54];
        return cell;
    } else if(indexPath.row == 5) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:NSLocalizedString(@"SynchronisationPreferencesTitle", @"")];
        return cell;
    } else if(indexPath.row == 6) {
        wifi3GCell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Wifi3G", @"") checkStatus:(currentConnectionSetting == ConnectionOptionWifi3G)];
        return wifi3GCell;
    } else if(indexPath.row == 7) {
        wifiCell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Wifi", @"") checkStatus:(currentConnectionSetting == ConnectionOptionWifi)];
        return wifiCell;
    } else if(indexPath.row == 8) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 9) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"DataRoaming", @"") subTitletext:NSLocalizedString(@"DataRoamingInfo", @"") SwitchButtonStatus:currentDataRoamingSetting];
        [cell.switchButton addTarget:self action:@selector(setDataRoaming:) forControlEvents:UIControlEventValueChanged];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 1:
            [self didTriggerPhotosVideos];
            break;
        case 2:
            [self didTriggerMusic];
            break;
        case 3:
            [self didTriggerDocuments];
            break;
        case 4:
            [self didTriggerContacts];
            break;
        case 6:
            [self setWifi3G];
            break;
        case 7:
            [self setWifi];
            break;
        default:
            break;
    }
}

- (void) didTriggerPhotosVideos {
    SettingsPhotosVideosController *photosVideosController = [[SettingsPhotosVideosController alloc] init];
    [self.nav pushViewController:photosVideosController animated:YES];
    
}

- (void) didTriggerMusic {
    SettingsMusicController *musicController = [[SettingsMusicController alloc] init];
    [self.nav pushViewController:musicController animated:YES];
}

- (void) didTriggerDocuments {
    SettingsDocumentsController *documentsController = [[SettingsDocumentsController alloc] init];
    [self.nav pushViewController:documentsController animated:YES];
}

- (void) didTriggerContacts {
    SettingsContactsController *contactsController = [[SettingsContactsController alloc] init];
    [self.nav pushViewController:contactsController animated:YES];
}

- (void)setWifi3G {
    currentConnectionSetting = ConnectionOptionWifi3G;
    [wifiCell hideTick];
    [wifi3GCell showTick];
}

- (void)setWifi {
    currentConnectionSetting = ConnectionOptionWifi;
    [wifi3GCell hideTick];
    [wifiCell showTick];
}

- (void)setDataRoaming:(id) sender {
    currentDataRoamingSetting = ((UISwitch *)sender).isOn;
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

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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return (currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncContactsSetting == EnableOptionOn) ? 3 : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 2 ? 1 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 2 ? 31 : 54;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: return 54; break;
        case 1: return 44; break;
        case 2: return 69; break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText;
    switch (section) {
        case 0: titleText = NSLocalizedString(@"AutoSynchronisation", @""); break;
        case 1: titleText = NSLocalizedString(@"SynchronisationPreferencesTitle", @""); break;
        default: titleText = @""; break;
    }
    return [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" headerText:titleText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Photos&Videos", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncPhotosVideosSetting] cellHeight:54];
            return cell;
        } else if(indexPath.row == 1) {
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Contacts", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:[super getEnableOptionName:currentSyncContactsSetting] cellHeight:54];
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            wifi3GCell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Wifi3G", @"") checkStatus:(currentConnectionSetting == ConnectionOptionWifi3G)];
            return wifi3GCell;
        } else if(indexPath.row == 1) {
            wifiCell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:NSLocalizedString(@"Wifi", @"") checkStatus:(currentConnectionSetting == ConnectionOptionWifi)];
            return wifiCell;
        }
    }
    else if (indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"DataRoaming", @"") subTitletext:NSLocalizedString(@"DataRoamingInfo", @"") SwitchButtonStatus:currentDataRoamingSetting];
        [cell.switchButton addTarget:self action:@selector(setDataRoaming:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch ([indexPath row]) {
            case 0:
                [self didTriggerPhotosVideos];
                break;
            case 1:
                [self didTriggerContacts];
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch ([indexPath row]) {
            case 0:
                [self setWifi3G];
                break;
            case 1:
                [self setWifi];
                break;
        }
    }
}

- (void) didTriggerPhotosVideos {
    SettingsPhotosVideosController *photosVideosController = [[SettingsPhotosVideosController alloc] init];
    [self.nav pushViewController:photosVideosController animated:YES];
    
}
/*
- (void) didTriggerMusic {
    SettingsMusicController *musicController = [[SettingsMusicController alloc] init];
    [self.nav pushViewController:musicController animated:YES];
}

- (void) didTriggerDocuments {
    SettingsDocumentsController *documentsController = [[SettingsDocumentsController alloc] init];
    [self.nav pushViewController:documentsController animated:YES];
}
*/
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

@end

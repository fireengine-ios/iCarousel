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
#import "Util.h"
#import "AppDelegate.h"

@interface SettingsUploadController ()

@end

@implementation SettingsUploadController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"AutomaticSynchronization", @"");
        photosVideosInfo = NSLocalizedString(@"Photos&VideosInfo", @"");
        photosVideosInfoHeight = [Util calculateHeightForText:photosVideosInfo forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
        contactsInfo = NSLocalizedString(@"ContactsInfo", @"");
        contactsInfoHeight = [Util calculateHeightForText:contactsInfo forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    currentSyncPhotosVideosSetting = [CacheUtil readCachedSettingSyncPhotosVideos];
    oldSyncPhotosVideosSetting = currentSyncPhotosVideosSetting;
    currentSyncContactsSetting = [CacheUtil readCachedSettingSyncContacts];
    oldSyncContactsSetting = currentSyncContactsSetting;
    currentConnectionSetting = [CacheUtil readCachedSettingSyncingConnectionType];
    oldConnectionSetting = currentConnectionSetting;
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (currentSyncPhotosVideosSetting != oldSyncPhotosVideosSetting) {
        if(currentSyncPhotosVideosSetting == EnableOptionOn) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group == nil) {
                    [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOn];
                    [APPDELEGATE.syncManager manuallyCheckIfAlbumChanged];
                }
            } failureBlock:^(NSError *error) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
            }];
        } else {
            [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
            [APPDELEGATE.uploadQueue cancelRemainingUploads];
        }
    }
    if (currentSyncContactsSetting != oldSyncContactsSetting)
        [CacheUtil writeCachedSettingSyncContacts:currentSyncContactsSetting];
    if (currentConnectionSetting != oldConnectionSetting)
        [CacheUtil writeCachedSettingSyncingConnectionType:currentConnectionSetting];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return (currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncContactsSetting == EnableOptionOn) ? 2 : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 2;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 31 : 54;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return 50; break;
            case 1: return photosVideosInfoHeight + 43; break;
            case 2: return 50; break;
            case 3: return contactsInfoHeight + 43; break;
            default: return 0;
                break;
        }
    } else if (indexPath.section == 1) {
        return 44;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText;
    if (section == 1)
        titleText = NSLocalizedString(@"SynchronizationPreferencesTitle", @"");
    else
        titleText = @"";
    return [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" headerText:titleText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Photos&Videos", @"") subTitletext: @"" SwitchButtonStatus:currentSyncPhotosVideosSetting == EnableOptionOn hasSeparator:NO];
            [cell.switchButton addTarget:self action:@selector(setSyncPhotosVideosSetting:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else if (indexPath.row == 1) {
            TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:photosVideosInfo contentTextColor:nil backgroundColor:[UIColor whiteColor] hasSeparator:YES];
            return cell;
        } else if(indexPath.row == 2) {
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Contacts", @"") subTitletext: @"" SwitchButtonStatus:currentSyncContactsSetting == EnableOptionOn hasSeparator:NO];
            [cell.switchButton addTarget:self action:@selector(setSyncContactsSetting:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else if (indexPath.row == 3) {
            TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:contactsInfo contentTextColor:nil backgroundColor:[UIColor whiteColor] hasSeparator:YES];
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
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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

- (void)setSyncPhotosVideosSetting:(id) sender {
    currentSyncPhotosVideosSetting = ((UISwitch *)sender).isOn ? EnableOptionOn : EnableOptionOff;
    [super drawPageContentTable];
}

- (void)setSyncContactsSetting:(id) sender {
    currentSyncContactsSetting = ((UISwitch *)sender).isOn ? EnableOptionOn : EnableOptionOff;
    [super drawPageContentTable];
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

@end

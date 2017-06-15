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
#import "CurioSDK.h"
#import "ReachabilityManager.h"
#import "LocationManager.h"
#import "MPush.h"

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
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    currentSyncPhotosVideosSetting = [CacheUtil readCachedSettingSyncPhotosVideos];
    oldSyncPhotosVideosSetting = currentSyncPhotosVideosSetting;
    currentConnectionSetting = [CacheUtil readCachedSettingSyncingConnectionType];
    oldConnectionSetting = currentConnectionSetting;
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    BOOL triggerAutoSync = NO;
    BOOL cancelAutoSync = NO;
    if (currentSyncPhotosVideosSetting != oldSyncPhotosVideosSetting) {
        if(currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncPhotosVideosSetting == EnableOptionAuto) {
            triggerAutoSync = YES;
            [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOn];
            [[CurioSDK shared] sendEvent:@"SyncOpened" eventValue:@"true"];
        } else {
            cancelAutoSync = YES;
            [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
            [[CurioSDK shared] sendEvent:@"SyncClosed" eventValue:@"true"];
            [[CurioSDK shared] sendEvent:@"SettingsAutoSyncPref" eventValue:@"closed"];
        }
    }
    if (currentConnectionSetting != oldConnectionSetting) {
        [CacheUtil writeCachedSettingSyncingConnectionType:currentConnectionSetting];
        
        if(currentConnectionSetting == ConnectionOptionWifi) {
            [[CurioSDK shared] sendEvent:@"SyncWifiOnly" eventValue:@"true"];
            [[CurioSDK shared] sendEvent:@"SettingsAutoSyncPref" eventValue:@"wifi"];
        } else {
            [[CurioSDK shared] sendEvent:@"SettingsAutoSyncPref" eventValue:@"any"];
        }
        
        //conn type değişmişse zaten yukarıda handle ediliyor
        if (currentSyncPhotosVideosSetting == oldSyncPhotosVideosSetting) {
            if(currentSyncPhotosVideosSetting == EnableOptionAuto || currentSyncPhotosVideosSetting == EnableOptionOn) {
                if([ReachabilityManager isReachableViaWiFi]) {
                    triggerAutoSync = YES;
                } else if([ReachabilityManager isReachableViaWWAN]) {
                    if(currentConnectionSetting == ConnectionOptionWifi3G) {
                        triggerAutoSync = YES;
                    } else {
                        cancelAutoSync = YES;
                    }
                }
            }
        }
    }

    if (currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncPhotosVideosSetting == EnableOptionAuto) {
        if(currentConnectionSetting == ConnectionOptionWifi) {
            [MPush hitTag:@"autosync" withValue:@"wifi"];
            [MPush hitEvent:@"autosync_wifi"];
        } else {
            [MPush hitTag:@"autosync" withValue:@"4g"];
            [MPush hitEvent:@"autosync_4g"];
        }
    } else {
        [MPush hitTag:@"autosync" withValue:@"off"];
        [MPush hitEvent:@"autosync_off"];
    }

    if(triggerAutoSync) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status != ALAuthorizationStatusAuthorized) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group == nil) {
                    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
                        [APPDELEGATE startAutoSync];
                    }
                }
            } failureBlock:^(NSError *error) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
            }];
        }
        else  {
            [APPDELEGATE startAutoSync];
        }
    }
//    if(triggerAutoSync) {
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            if(group == nil) {
//                [APPDELEGATE startAutoSync];
//            }
//        } failureBlock:^(NSError *error) {
//            [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
//        }];
//    }

    if(cancelAutoSync) {
        [[LocationManager sharedInstance] stopLocationManager];
        [[UploadQueue sharedInstance] cancelRemainingUploads];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return (currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncPhotosVideosSetting == EnableOptionAuto) ? 2 : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
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
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Photos&Videos", @"") subTitletext: @"" SwitchButtonStatus:(currentSyncPhotosVideosSetting == EnableOptionOn || currentSyncPhotosVideosSetting == EnableOptionAuto) hasSeparator:NO];
            [cell.switchButton addTarget:self action:@selector(setSyncPhotosVideosSetting:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else if (indexPath.row == 1) {
            TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:photosVideosInfo contentTextColor:nil backgroundColor:[UIColor whiteColor] hasSeparator:YES];
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

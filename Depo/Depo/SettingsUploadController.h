//
//  SettingsUploadController.h
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"

@interface SettingsUploadController : SettingsBaseViewController {
    TitleCell *wifi3GCell;
    TitleCell *wifiCell;
    int currentConnectionSetting;
    int oldConnectionSetting;
    int currentSyncPhotosVideosSetting;
    int oldSyncPhotosVideosSetting;
    int currentSyncContactsSetting;
    int oldSyncContactsSetting;
    NSString *photosVideosInfo;
    NSString *contactsInfo;
    float photosVideosInfoHeight;
    float contactsInfoHeight;
}

@end

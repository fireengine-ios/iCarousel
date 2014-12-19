//
//  SettingsNotificationsController.h
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"

@interface SettingsNotificationsController : SettingsBaseViewController {
    NSString *infoText;
    double infoTextHeight;
    NSInteger currentNotificationSetting;
    NSInteger oldNotificationSetting;
}

@end

//
//  SettingsConnectedDevicesController.h
//  Depo
//
//  Created by Mustafa Talha Celik on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"
#import "DeviceDao.h"

@interface SettingsConnectedDevicesController : SettingsBaseViewController {
    DeviceDao *deviceDao;
    NSMutableArray *devicesArray;
}

@end

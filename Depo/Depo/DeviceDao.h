//
//  DeviceDao.h
//  Depo
//
//  Created by Salih Topcu on 12.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "BaseDao.h"
#import "Device.h"

@interface DeviceDao : BaseDao

- (void) requestConnectedDevices;

@end

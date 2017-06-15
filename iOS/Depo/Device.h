//
//  Device.h
//  Depo
//
//  Created by Salih Topcu on 12.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

typedef enum {
    DeviceTypeOther = 0,
    DeviceTypeAndroid,
    DeviceTypeIpad,
    DeviceTypeIphone,
    DeviceTypeMac,
    DeviceTypeWindows
} DeviceType;

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int type;

@end

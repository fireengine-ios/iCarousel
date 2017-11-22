//
//  CurioResourceUtils.h
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 29.07.2015.
//  Copyright © 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

__TVOS_UNAVAILABLE
@interface CurioResourceUtil : NSObject <CBCentralManagerDelegate>

@property (nonatomic) CBCentralManager *bluetoothManager;

/**
 Holds the bluetoothState. 	unknown, resetting, unsupported, unauthorized, poweredOff, poweredOn.
 */
@property (strong, nonatomic) NSString *bluetoothState;

@property (assign, nonatomic) BOOL hasBluetoothState;

/**
 Holds the battery level. Can have values from 0 to 100. -1 if is unknown.
 */
@property (strong, nonatomic) NSString *batteryLevel;

/**
 Holds the battery state.     
 
 unknown,
 unplugged,   // on battery, discharging
 charging,    // plugged in, less than 100%
 full,        // plugged in, at 100%
 */
@property (strong, nonatomic) NSString *batteryState;

@property (strong, nonatomic) NSNumber *totalSpace;

@property (strong, nonatomic) NSNumber *totalFreeSpace;

/**
 Returns shared instance of CurioUtil
 
 @return CurioUtil shared instance
 */
+ (CS_INSTANCETYPE) shared;


@end

//
//  CurioResourceUtils.m
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 29.07.2015.
//  Copyright © 2015 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@implementation CurioResourceUtil

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id) init {
    if ((self = [super init])) {
        // Register for battery level and state change notifications.
        
        [self getFreeDiskspace];
        
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        self.batteryLevel = [NSString stringWithFormat:@"%.f", [UIDevice currentDevice].batteryLevel * 100];;
        CS_Log_Info(@"batteryLevel: %@",self.batteryLevel);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryStateChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification object:nil];


        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                 queue:nil
                                                               options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                   forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
    return self;
}

#pragma mark - Battery notifications

- (void)updateBatteryLevel
{
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        self.batteryLevel = @"unknown";
    }
    else {
        self.batteryLevel = [NSString stringWithFormat:@"%.f", batteryLevel * 100];
    }
    
    //[[CurioSDK shared] sendEvent:@"BatterLevelChanged" eventValue:self.batteryLevel];
    CS_Log_Info(@"batteryLevel: %@",self.batteryLevel);

}

- (void)updateBatteryState
{
    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    if (currentState == UIDeviceBatteryStateUnknown) {
        self.batteryState = @"unknown";
    } else if (currentState == UIDeviceBatteryStateUnplugged) {
        self.batteryState = @"unplugged";
    } else if (currentState == UIDeviceBatteryStateCharging) {
        self.batteryState = @"charging";
    } else if (currentState == UIDeviceBatteryStateFull) {
        self.batteryState = @"full";
    }
    
    //[[CurioSDK shared] sendEvent:@"BatterStateChanged" eventValue:self.batteryState];
    CS_Log_Info(@"batteryState: %@",self.batteryState);
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    [self updateBatteryLevel];
    [self updateBatteryState];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    switch(_bluetoothManager.state)
    {
        
        case CBCentralManagerStateUnknown: self.bluetoothState = @"off"; break;
        case CBCentralManagerStateResetting: self.bluetoothState = @"off"; break;
        case CBCentralManagerStateUnsupported: self.bluetoothState = @"off"; break;
        case CBCentralManagerStateUnauthorized: self.bluetoothState = @"no permission"; break;
        case CBCentralManagerStatePoweredOff: self.bluetoothState = @"off"; break;
        case CBCentralManagerStatePoweredOn: self.bluetoothState = @"on"; break;

            
        default: self.bluetoothState = @"off"; break;
    }
    
    self.hasBluetoothState = YES;
    CS_Log_Info(@"bluetoothState: %@",self.bluetoothState);
}

-(void) getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        CS_Log_Info(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        CS_Log_Info(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
 
    self.totalSpace = [NSNumber numberWithUnsignedLongLong:((totalSpace/1024ll)/1024ll)];
    self.totalFreeSpace = [NSNumber numberWithUnsignedLongLong:((totalFreeSpace/1024ll)/1024ll)];
}

@end

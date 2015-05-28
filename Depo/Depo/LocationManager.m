//
//  LocationManager.m
//  Depo
//
//  Created by Mahir on 11/05/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "LocationManager.h"
#import "SyncManager.h"
#import "AppConstants.h"
#import "AppUtil.h"
#import "SyncUtil.h"
#import "UploadQueue.h"

@implementation LocationManager

@synthesize delegate;
@synthesize locManager;

+ (LocationManager *) sharedInstance {
    static LocationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocationManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if(self = [super init]) {
    }
    return self;
}

- (void) initializeLocationManager {
    if(![LocationManager sharedInstance].locManager) {
        [LocationManager sharedInstance].locManager = [[CLLocationManager alloc] init];
    }
    [LocationManager sharedInstance].locManager.delegate = self;
    [LocationManager sharedInstance].locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [LocationManager sharedInstance].locManager.distanceFilter = 100.0f;
    [LocationManager sharedInstance].locManager.pausesLocationUpdatesAutomatically = NO;
}

/*
- (void) requestPermission {
    if ([CLLocationManager locationServicesEnabled]) {
        [[LocationManager sharedInstance] initializeLocationManager];
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            SEL authorizationSel = NSSelectorFromString(@"requestAlwaysAuthorization");
            if ([self.locManager respondsToSelector:authorizationSel]) {
                [self.locManager requestAlwaysAuthorization];
            }
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [delegate locationPermissionGranted];
        }
    } else {
        [delegate locationPermissionError:NSLocalizedString(@"LocationNotEnabled", @"")];
    }
}
 */

- (void) startLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location services enabled");
        [[LocationManager sharedInstance] initializeLocationManager];
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            SEL authorizationSel = NSSelectorFromString(@"requestAlwaysAuthorization");
            if ([[LocationManager sharedInstance].locManager respondsToSelector:authorizationSel]) {
                [[LocationManager sharedInstance].locManager requestAlwaysAuthorization];
            } else {
                if(delegate) {
                    [delegate locationPermissionGranted];
                }
                NSLog(@"Location services calling startMonitoringSignificantLocationChanges");
                [[LocationManager sharedInstance].locManager startMonitoringSignificantLocationChanges];
            }
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            if(delegate) {
                [delegate locationPermissionGranted];
            }
            NSLog(@"Location services calling startMonitoringSignificantLocationChanges");
            [[LocationManager sharedInstance].locManager startMonitoringSignificantLocationChanges];
        }
    } else {
        NSLog(@"Location services disabled");
    }
}

- (void) stopLocationManager {
    if([LocationManager sharedInstance].locManager) {
        [[LocationManager sharedInstance].locManager stopMonitoringSignificantLocationChanges];
        [LocationManager sharedInstance].locManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        if(delegate) {
            [delegate locationPermissionGranted];
        }
        NSLog(@"Location services calling startMonitoringSignificantLocationChanges");
        [[LocationManager sharedInstance].locManager startMonitoringSignificantLocationChanges];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        if(delegate) {
            [delegate locationPermissionGranted];
        }
        NSLog(@"Location services calling startMonitoringSignificantLocationChanges");
        [[LocationManager sharedInstance].locManager startMonitoringSignificantLocationChanges];
    } else {
        if(delegate) {
            [delegate locationPermissionDenied];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"At locationManager:didUpdateLocations:");
    
    NSDate *lastUpdateDate = [SyncUtil readLastLocUpdateTime];
    if(lastUpdateDate != nil && [[NSDate date] timeIntervalSinceDate:lastUpdateDate] < 30) {
        NSLog(@"At locationManager:didUpdateLocations: still under 30 seconds, ignoring...");
        return;
    }
    
    [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
    }];

    //TODO sil
    [AppUtil sendLocalNotificationForDate:[NSDate date] withMessage:@"startMonitoringSignificantLocationChanges returns location"];
    
    [SyncUtil writeLastLocUpdateTime:[NSDate date]];
    
    //TODO check
//    [SyncUtil unlockAutoSyncBlockInProgress];
    
    [[SyncManager sharedInstance] decideAndStartAutoSync];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"At locationManager:didFailWithError:");
}

@end

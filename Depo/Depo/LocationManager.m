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

@implementation LocationManager

@synthesize delegate;
@synthesize locManager;

+ (LocationManager *) sharedInstance {
    static LocationManager *sharedInstance = nil;
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
    if(!self.locManager) {
        self.locManager = [[CLLocationManager alloc] init];
    }
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locManager.distanceFilter = 10.0f;
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
            if ([self.locManager respondsToSelector:authorizationSel]) {
                [self.locManager requestAlwaysAuthorization];
            } else {
                if(delegate) {
                    [delegate locationPermissionGranted];
                }
                [self.locManager startMonitoringSignificantLocationChanges];
            }
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            if(delegate) {
                [delegate locationPermissionGranted];
            }
            [self.locManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void) stopLocationManager {
    if(self.locManager) {
        [self.locManager stopMonitoringSignificantLocationChanges];
        self.locManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        if(delegate) {
            [delegate locationPermissionGranted];
        }
        [self.locManager startMonitoringSignificantLocationChanges];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        if(delegate) {
            [delegate locationPermissionGranted];
        }
        [self.locManager startMonitoringSignificantLocationChanges];
    } else {
        if(delegate) {
            [delegate locationPermissionDenied];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"At locationManager:didUpdateLocations:");
    [[SyncManager sharedInstance] decideAndStartAutoSync];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"At locationManager:didFailWithError:");
}

@end

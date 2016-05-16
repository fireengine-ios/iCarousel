//
//  AccurateLocationManager.m
//  Depo
//
//  Created by Mahir Tarlan on 16/05/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "AccurateLocationManager.h"

@implementation AccurateLocationManager

@synthesize delegate;
@synthesize locManager;
@synthesize currentLocation;

+ (AccurateLocationManager *) sharedInstance {
    static AccurateLocationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AccurateLocationManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if(self = [super init]) {
    }
    return self;
}

- (void) initializeLocationManager {
    if(![AccurateLocationManager sharedInstance].locManager) {
        [AccurateLocationManager sharedInstance].locManager = [[CLLocationManager alloc] init];
    }
    [AccurateLocationManager sharedInstance].locManager.delegate = self;
    [AccurateLocationManager sharedInstance].locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [AccurateLocationManager sharedInstance].locManager.distanceFilter = 100.0f;
    [AccurateLocationManager sharedInstance].locManager.pausesLocationUpdatesAutomatically = NO;
}

- (void) startLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        [[AccurateLocationManager sharedInstance] initializeLocationManager];
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            SEL authorizationSel = NSSelectorFromString(@"requestAlwaysAuthorization");
            if ([[AccurateLocationManager sharedInstance].locManager respondsToSelector:authorizationSel]) {
                [[AccurateLocationManager sharedInstance].locManager requestAlwaysAuthorization];
            } else {
                [[AccurateLocationManager sharedInstance].locManager startUpdatingLocation];
            }
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [[AccurateLocationManager sharedInstance].locManager startUpdatingLocation];
        } else {
            if(delegate) {
                [delegate accurateLocationManagerPermissionDenied];
            }
        }
    } else {
        if(delegate) {
            [delegate accurateLocationManagerPermissionDenied];
        }
    }
}

- (void) stopLocationManager {
    if([AccurateLocationManager sharedInstance].locManager) {
        [[AccurateLocationManager sharedInstance].locManager stopMonitoringSignificantLocationChanges];
        [AccurateLocationManager sharedInstance].locManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[AccurateLocationManager sharedInstance].locManager startUpdatingLocation];
    } else {
        if(delegate) {
            [delegate accurateLocationManagerPermissionDenied];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    if(delegate) {
        [delegate accurateLocationManagerDidReceiveLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(delegate) {
        [delegate accurateLocationManagerDidReceiveError:[error localizedDescription]];
    }
}


@end

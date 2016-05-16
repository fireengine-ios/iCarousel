//
//  LocationManager.h
//  Depo
//
//  Created by Mahir on 11/05/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>
- (void) locationPermissionGranted;
- (void) locationPermissionDenied;
- (void) locationPermissionError:(NSString *) errorMessage;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) id<LocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (LocationManager *) sharedInstance;
- (void) startLocationManager;
- (void) stopLocationManager;

@end

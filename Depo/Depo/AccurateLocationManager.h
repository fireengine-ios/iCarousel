//
//  AccurateLocationManager.h
//  Depo
//
//  Created by Mahir Tarlan on 16/05/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol AccurateLocationManagerDelegate <NSObject>
- (void) accurateLocationManagerDidReceiveLocation;
- (void) accurateLocationManagerPermissionDenied;
- (void) accurateLocationManagerDidReceiveError:(NSString *) errorMessage;
@end

@interface AccurateLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) id<AccurateLocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (AccurateLocationManager *) sharedInstance;
- (void) startLocationManager;
- (void) stopLocationManager;

@end

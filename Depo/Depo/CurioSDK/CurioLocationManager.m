//
//  CurioLocationManager.m
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 5.02.2015.
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "CurioLocationManager.h"

@interface CurioLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CurioLocationManager

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        curioLocationQueue = [NSOperationQueue new];
        [curioLocationQueue setMaxConcurrentOperationCount:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPreviouslyFailedLocationDataToServer:) name:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
    }
    return self;
}

#pragma mark - Send location public methods

- (void)sendLocation {
    [self fetchLocationData];
}

#pragma mark - Fetchlocation methods

- (void)fetchLocationData {
    if ([self isLocationEnabled])
        [self startStandardLocationUpdates];
}

- (BOOL)isLocationEnabled {
    if (!([CLLocationManager locationServicesEnabled])
        || !([[[CurioSettings shared] fetchLocationEnabled] boolValue])
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return NO;
    }
    return YES;
}

- (void)startStandardLocationUpdates {
    // Create the location manager if this object does not
    // already have one.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events.
        self.locationManager.distanceFilter = kCLDistanceFilterNone; // meters //kCLDistanceFilterNone is used for all movements
        
        // iOS8+
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
#if TARGET_OS_TV
        [self.locationManager requestLocation];
#else
        [self.locationManager startUpdatingLocation];
#endif
        
        
    });
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
#if TARGET_OS_TV
        [self.locationManager requestLocation];
#else
        [self.locationManager startUpdatingLocation];
#endif
    }
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSTimeInterval maxValidLocationTimeInterval = [[[CurioSettings shared] maxValidLocationTimeInterval] doubleValue];
    
    CS_Log_Debug(@"\rLatitude %+.6f\rLongitude %+.6f\rHow Recent %f\r", location.coordinate.latitude,location.coordinate.longitude, howRecent);
    
    if (fabs(howRecent) <= maxValidLocationTimeInterval) {
        // If the event is recent, do something with it.
        [self.locationManager stopUpdatingLocation];

        NSNumber *latitudeNumber = [NSNumber numberWithDouble:location.coordinate.latitude];
        NSNumber *longitudeNumber = [NSNumber numberWithDouble:location.coordinate.longitude];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              latitudeNumber.stringValue, CURKeyLatitude,
                              longitudeNumber.stringValue, CURKeyLongitude,
                              nil];
        [self sendLocationData:dict];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

#pragma mark - Send data to Curio methods

- (void) sendPreviouslyFailedLocationDataToServer:(id) notif {
    
    NSArray *rLocations = [[CurioDBToolkit shared] getStoredLocationData];
    
    CS_Log_Info(@"Posting %lu remaining locations",(unsigned long)rLocations.count);
    
    for (CurioLocationData *loc in rLocations) {
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        
        if (loc.latitude != nil && ![loc.latitude isEqualToString:@""] ) {
            [userInfo setObject:loc.latitude forKey: CURKeyLatitude];
        }
        
        if (loc.longitude != nil && ![loc.longitude isEqualToString:@""] ) {
            [userInfo setObject:loc.longitude forKey: CURKeyLongitude];
        }
        
        [self sendLocationData:userInfo];
        
    }
    
    [[CurioDBToolkit shared] deleteStoredLocationData:rLocations];
    
}

- (void) sendLocationData:(NSDictionary *)userInfo {
    
    __weak CurioLocationManager *weakSelf = self;
    
    [curioLocationQueue addOperationWithBlock:^{
        
        @synchronized(weakSelf) {
            
            if (![[CurioSDK shared] sessionCodeRegisteredOnServer]) {
                
                [[CurioDBToolkit shared] addLocationData:
                 [[CurioLocationData alloc] init:[[CurioUtil shared] nanos]
                                 latitude:(userInfo != nil ? [userInfo objectForKey: CURKeyLatitude] : nil)
                                      longitude:(userInfo != nil ? [userInfo objectForKey: CURKeyLongitude] : nil)]];
                
                CS_Log_Info(@"Adding location to DB because not received an accepted session code yet");
                
                return;
            }
            
            
            NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],CS_SERVER_URL_SUFFIX_LOCATION_DATA];
            
            NSURL *url = [NSURL URLWithString:sUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setHTTPShouldHandleCookies:NO];
            [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
            
            NSString *postBody = [[CurioUtil shared] dictToPostBody:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [[CurioUtil shared] vendorIdentifier], CURHttpParamVisitorCode,
                                                                     [[CurioSettings shared] trackingCode], CURHttpParamTrackingCode,
                                                                     [[CurioSDK shared] sessionCode], CURKeySessionCode,
                                                                     userInfo != nil ? [userInfo objectForKey: CURKeyLatitude] : nil, CURHttpParamLatitude,
                                                                     userInfo != nil ? [userInfo objectForKey: CURKeyLongitude] : nil, CURHttpParamLongitude,
                                                                     nil]];
            
            NSData *dataPostBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
            
            CS_Log_Debug(@"\r\rSendLocationData REQUEST;\rURL: %@,\rPost body:\r%@\r\r",sUrl,[postBody stringByReplacingOccurrencesOfString:@"&" withString:@"\r"]);
            
            [request setHTTPBody:dataPostBody];
            
            
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            
            CS_Log_Debug(@"\r\rRESPONSE for URL: %@,\rStatus code: %ld,\rResponse string: %@\r\r",sUrl,(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            BOOL failed = FALSE;
            
            if ((long)httpResponse.statusCode != 200) {
                CS_Log_Warning(@"Not ok: %ld, %@",(long)httpResponse.statusCode,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                failed = TRUE;
            }
            if (error != nil) {
                CS_Log_Warning(@"Warning: %ld , %@ %@",(long)error.code, sUrl, error.localizedDescription);
                
                failed = TRUE;
            }
            
            
            if (failed) {
                
                [[CurioDBToolkit shared] addLocationData:
                 [[CurioLocationData alloc] init:[[CurioUtil shared] nanos]
                                        latitude:(userInfo != nil ? [userInfo objectForKey: CURKeyLatitude] : nil)
                                       longitude:(userInfo != nil ? [userInfo objectForKey: CURKeyLongitude] : nil)]];
                
                CS_Log_Warning(@"Adding location to DB because it was not successfull");
                
            }

            
        }
        
    }];
}

@end

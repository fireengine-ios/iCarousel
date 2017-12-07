//
//  CurioLocationData.m
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 6.02.2015.
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@implementation CurioLocationData

- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


- (id) init:(NSString *) lId
   latitude:(NSString *) latitude
  longitude:(NSString *) longitude
{
    self = [self init];
    if (self) {
        _lId = lId;
        _latitude = latitude;
        _longitude = longitude;
    }
    
    return self;
}

- (NSDictionary *) asDict {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    
    CS_SET_DICT_IF_NOT_NIL(ret, _latitude, CURKeyLatitude);
    CS_SET_DICT_IF_NOT_NIL(ret, _longitude, CURKeyLongitude);
    CS_SET_DICT_IF_NOT_NIL(ret, _lId, CURKeyLocationId);
    
    return ret;
}

@end

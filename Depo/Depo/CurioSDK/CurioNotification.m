//
//  CurioNotification.m
//  CurioIOSSDKSample
//
//  Created by Marcus Frex on 23/12/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@implementation CurioNotification


- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


- (id) init:(NSString *) nId
deviceToken:(NSString *) deviceToken
  pushId:(NSString *) pushId
 {
    self = [self init];
    if (self) {
        
    }
    
     _nId = nId;
     _deviceToken = deviceToken;
     _pushId = pushId;
     
    return self;
}

- (NSDictionary *) asDict {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    
    CS_SET_DICT_IF_NOT_NIL(ret, _deviceToken, @"deviceToken");
    CS_SET_DICT_IF_NOT_NIL(ret, _pushId, @"pushId");
    CS_SET_DICT_IF_NOT_NIL(ret, _nId, @"nid");
    
    return ret;
}

@end

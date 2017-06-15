//
//  CurioNotification.m
//  CurioIOSSDKSample
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Marcus Frex on 23/12/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

@implementation CurioPushData


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
        _nId = nId;
        _deviceToken = deviceToken;
        _pushId = pushId;
    }
     
    return self;
}

- (NSDictionary *) asDict {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    
    CS_SET_DICT_IF_NOT_NIL(ret, _deviceToken, CURKeyDeviceToken);
    CS_SET_DICT_IF_NOT_NIL(ret, _pushId, CURHttpParamPushId);
    CS_SET_DICT_IF_NOT_NIL(ret, _nId, CURKeyNotificationId);
    
    return ret;
}

@end

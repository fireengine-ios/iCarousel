//
//  CurioNotification.h
//  CurioIOSSDKSample
//
//  Created by Marcus Frex on 23/12/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurioNotification : NSObject

@property (strong, nonatomic) NSString   *nId;
@property (strong, nonatomic) NSString   *deviceToken;
@property (strong, nonatomic) NSString   *pushId;

- (NSDictionary *) asDict;

- (id) init:(NSString *) nId
deviceToken:(NSString *) deviceToken
  pushId:(NSString *) pushId;

@end

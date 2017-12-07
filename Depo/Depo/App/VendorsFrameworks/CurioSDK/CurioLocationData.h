//
//  CurioLocationData.h
//  CurioIOSSDKSample
//
//  Created by Abdulbasıt Tanhan on 6.02.2015.
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurioLocationData : NSObject

@property (strong, nonatomic) NSString   *lId;
@property (strong, nonatomic) NSString   *latitude;
@property (strong, nonatomic) NSString   *longitude;

- (NSDictionary *) asDict;

- (id) init:(NSString *) lId
   latitude:(NSString *) latitude
  longitude:(NSString *) longitude;

@end

//
//  Quota.h
//  Depo
//
//  Created by Salih GUC on 25/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quota : NSObject

@property (nonatomic) long long quotaBytes;
@property (nonatomic) long long quotaCount;
@property (nonatomic) long long bytesUsed;
@property (nonatomic) bool quotaExceeded;
@property (nonatomic) int objectCount;

-(Quota *)initWithQuota:(Quota *)quota;

@end

/* 
 {
 "quotaBytes": "54760833024",
 "quotaCount": "1000000",
 "bytesUsed": "70656969",
 "quotaExceeded": "false",
 "objectCount": "37"
 }
 */
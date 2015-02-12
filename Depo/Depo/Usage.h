//
//  Usage.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usage : NSObject

@property (nonatomic) long long imageUsage;
@property (nonatomic) long long musicUsage;
@property (nonatomic) long long contactUsage;
@property (nonatomic) long long otherUsage;
@property (nonatomic) long long videoUsage;
@property (nonatomic) long long remainingStorage;
@property (nonatomic) long long usedStorage;
@property (nonatomic) long long totalStorage;

@end

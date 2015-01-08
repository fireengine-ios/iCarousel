//
//  Usage.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usage : NSObject

@property (nonatomic) long imageUsage;
@property (nonatomic) long musicUsage;
@property (nonatomic) long contactUsage;
@property (nonatomic) long otherUsage;
@property (nonatomic) long videoUsage;
@property (nonatomic) long remainingStorage;
@property (nonatomic) long usedStorage;
@property (nonatomic) long totalStorage;

@end

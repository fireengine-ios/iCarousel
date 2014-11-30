//
//  Usage.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usage : NSObject

@property (nonatomic) float imageUsage;
@property (nonatomic) float musicUsage;
@property (nonatomic) float contactUsage;
@property (nonatomic) float otherUsage;
@property (nonatomic) float remainingStorage;
@property (nonatomic) float totalStorage;

- (float) totalUsage;

@end

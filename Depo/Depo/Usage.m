//
//  Usage.m
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "Usage.h"

@implementation Usage

@synthesize imageUsage;
@synthesize musicUsage;
@synthesize contactUsage;
@synthesize otherUsage;
@synthesize remainingStorage;
@synthesize totalStorage;

- (float) totalUsage {
    return imageUsage + musicUsage + contactUsage + otherUsage;
}

@end

//
//  Quota.m
//  Depo
//
//  Created by Salih GUC on 25/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "Quota.h"

@implementation Quota

@synthesize quotaBytes;
@synthesize quotaCount;
@synthesize bytesUsed;
@synthesize quotaExceeded;
@synthesize objectCount;

- (id) init {
    if(self = [super init]) {
    }
    return self;
}

-(Quota *)initWithQuota:(Quota *)quota {
    if (self = [super init]) {
        self.quotaBytes = quota.quotaBytes;
        self.quotaCount = quota.quotaCount;
        self.bytesUsed = quota.bytesUsed;
        self.quotaExceeded = quota.quotaExceeded;
        self.objectCount = quota.objectCount;
    }
    return self;
}

@end
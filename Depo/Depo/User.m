//
//  User.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "User.h"
#import "CacheUtil.h"

@implementation User

@synthesize profileImgUrl;
@synthesize fullName;
@synthesize msisdn;
@synthesize password;

- (id) init {
    if(self = [super init]) {
        self.msisdn = [CacheUtil readCachedMsisdn];
        self.password = [CacheUtil readCachedPassword];
    }
    return self;
}

@end

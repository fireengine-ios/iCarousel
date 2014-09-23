//
//  AppSession.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppSession.h"

@implementation AppSession

@synthesize user;
@synthesize authToken;

- (id) init {
    if(self = [super init]) {
        //TODO
        self.user = [[User alloc] init];
        self.user.profileImgUrl = @"http://s.turkcell.com.tr/profile_img/532/225/cjXlJsupflKCNP2jmf23A.jpg?wruN55vtoNoCItHngeSqW9QN4XM1Y9qgZHRnZnp8bGOut1pQZOk1!207944990!1411130039277";
        self.user.fullName = @"Mahir Kemal Tarlan";
        self.user.msisdn = @"5322109090";
        self.user.password = @"5322109090";
    }
    return self;
}

@end

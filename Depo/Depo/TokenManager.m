//
//  TokenManager.m
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "TokenManager.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "User.h"

@implementation TokenManager

@synthesize delegate;

- (id) init {
    if(self = [super init]) {
        tokenDao = [[RequestTokenDao alloc] init];
        tokenDao.delegate = self;
        tokenDao.successMethod = @selector(tokenDaoSuccessCallback);
        tokenDao.failMethod = @selector(tokenDaoFailCallback:);
        
        baseUrlDao = [[RequestBaseUrlDao alloc] init];
        baseUrlDao.delegate = self;
        baseUrlDao.successMethod = @selector(baseUrlDaoSuccessCallback);
        baseUrlDao.failMethod = @selector(baseUrlDaoFailCallback:);
    }
    return self;
}

- (void) requestToken {
    if(APPDELEGATE.session.user) {
        if(APPDELEGATE.session.user.msisdn && APPDELEGATE.session.user.password) {
            [tokenDao requestTokenForMsisdn:APPDELEGATE.session.user.msisdn andPassword:APPDELEGATE.session.user.password];
        }
    }
    [delegate tokenManagerInadequateInfo];
}

- (void) requestBaseUrl {
    [baseUrlDao requestBaseUrl];
}

- (void) tokenDaoSuccessCallback {
    [delegate tokenManagerDidReceiveToken];
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingToken];
}

- (void) baseUrlDaoSuccessCallback {
    [delegate tokenManagerDidReceiveBaseUrl];
}

- (void) baseUrlDaoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingBaseUrl];
}

@end

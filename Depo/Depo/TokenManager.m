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
#import "CacheUtil.h"

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
        
        userInfoDao = [[AccountInfoDao alloc] init];
        userInfoDao.delegate = self;
        userInfoDao.successMethod = @selector(userInfoSuccessCallback:);
        userInfoDao.failMethod = @selector(userInfoFailCallback:);
        
        radiusDao = [[RadiusDao alloc] init];
        radiusDao.delegate = self;
        radiusDao.successMethod = @selector(tokenDaoSuccessCallback);
        radiusDao.failMethod = @selector(tokenDaoFailCallback:);
    }
    return self;
}

- (void) requestRadiusLogin {
    [radiusDao requestRadiusLogin];
}

- (void) requestToken {
    [tokenDao requestTokenByRememberMe];
}

- (void) requestBaseUrl {
    [baseUrlDao requestBaseUrl];
}

- (void) requestUserInfo {
    [userInfoDao requestAccountInfo];
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

- (void) userInfoSuccessCallback:(User *) enrichedUser {
    APPDELEGATE.session.user = enrichedUser;
    [delegate tokenManagerDidReceiveUserInfo];
}

- (void) userInfoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingUserInfo];
}

@end

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
#import "Reachability.h"

#import "RequestTokenDao.h"
#import "RequestBaseUrlDao.h"
#import "AccountInfoDao.h"
#import "RadiusDao.h"
#import "LogoutDao.h"
#import "ConstantsDao.h"

@implementation TokenManager

@synthesize delegate;
@synthesize processDelegate;
@synthesize processDelegateTaskId;

- (id) init {
    if(self = [super init]) {
        tokenDao = [[RequestTokenDao alloc] init];
        tokenDao.delegate = self;
        tokenDao.successMethod = @selector(tokenDaoSuccessCallback);
        tokenDao.failMethod = @selector(tokenDaoFailCallback:);
        
        tokenWithinProcessDao = [[RequestTokenDao alloc] init];
        tokenWithinProcessDao.delegate = self;
        tokenWithinProcessDao.successMethod = @selector(tokenWithinProcessDaoSuccessCallback);
        tokenWithinProcessDao.failMethod = @selector(tokenWithinProcessDaoFailCallback:);
        
        baseUrlDao = [[RequestBaseUrlDao alloc] init];
        baseUrlDao.delegate = self;
        baseUrlDao.successMethod = @selector(baseUrlDaoSuccessCallback);
        baseUrlDao.failMethod = @selector(baseUrlDaoFailCallback:);
        
        baseUrlWithinProcessDao = [[RequestBaseUrlDao alloc] init];
        baseUrlWithinProcessDao.delegate = self;
        baseUrlWithinProcessDao.successMethod = @selector(baseUrlWithinProcessDaoSuccessCallback);
        baseUrlWithinProcessDao.failMethod = @selector(baseUrlWithinProcessDaoFailCallback:);
        
        userInfoDao = [[AccountInfoDao alloc] init];
        userInfoDao.delegate = self;
        userInfoDao.successMethod = @selector(userInfoSuccessCallback:);
        userInfoDao.failMethod = @selector(userInfoFailCallback:);
        
        userInfoWithinProcessDao = [[AccountInfoDao alloc] init];
        userInfoWithinProcessDao.delegate = self;
        userInfoWithinProcessDao.successMethod = @selector(userInfoWithinProcessSuccessCallback:);
        userInfoWithinProcessDao.failMethod = @selector(userInfoWithinProcessFailCallback:);
        
        radiusDao = [[RadiusDao alloc] init];
        radiusDao.delegate = self;
        radiusDao.successMethod = @selector(tokenDaoSuccessCallback);
        radiusDao.failMethod = @selector(tokenDaoFailCallback:);

        radiusWithinProcessDao = [[RadiusDao alloc] init];
        radiusWithinProcessDao.delegate = self;
        radiusWithinProcessDao.successMethod = @selector(tokenWithinProcessDaoSuccessCallback);
        radiusWithinProcessDao.failMethod = @selector(tokenWithinProcessDaoFailCallback:);

        constantsDao = [[ConstantsDao alloc] init];
        constantsDao.delegate = self;
        constantsDao.successMethod = @selector(constantsSuccessCallback);
        constantsDao.failMethod = @selector(constantsFailCallback:);
        
        logoutDao = [[LogoutDao alloc] init];
//        logoutDao.delegate = self;
//        logoutDao.successMethod = @selector(logoutSuccessCallback);
//        logoutDao.failMethod = @selector(logoutFailCallback:);
    }
    return self;
}

- (void) requestRadiusLogin {
    [radiusDao requestRadiusLogin];
}

- (void) requestToken {
    [tokenDao requestTokenByRememberMe];
}

- (void) requestTokenByMsisdn:(NSString *) msisdn andPass:(NSString *) pass shouldRememberMe:(BOOL) rememberMeFlag {
    [tokenDao requestTokenForMsisdn:msisdn andPassword:pass shouldRememberMe:rememberMeFlag];
}

- (void) requestBaseUrl {
    [baseUrlDao requestBaseUrl];
}

- (void) requestUserInfo {
    [userInfoDao requestAccountInfo];
}

- (void) requestLogout {
    [logoutDao requestLogout];
}

- (void) tokenDaoSuccessCallback {
    if(APPDELEGATE.session.newUserFlag) {
        [delegate tokenManagerProvisionNeeded];
    } else if(APPDELEGATE.session.migrationUserFlag) {
        [delegate tokenManagerMigrationInProgress];
    } else {
        [delegate tokenManagerDidReceiveToken];
    }
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingToken];
}

- (void) tokenWithinProcessDaoSuccessCallback {
    [userInfoWithinProcessDao requestAccountInfo];
}

- (void) tokenWithinProcessDaoFailCallback:(NSString *) errorMessage {
    [processDelegate tokenManagerWithinProcessDidFailReceivingTokenFor:self.processDelegateTaskId];
}

- (void) baseUrlDaoSuccessCallback {
    [delegate tokenManagerDidReceiveBaseUrl];
}

- (void) baseUrlDaoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingBaseUrl];
}

- (void) baseUrlWithinProcessDaoSuccessCallback {
    [processDelegate tokenManagerWithinProcessDidReceiveTokenFor:self.processDelegateTaskId];
}

- (void) baseUrlWithinProcessDaoFailCallback:(NSString *) errorMessage {
    [processDelegate tokenManagerWithinProcessDidFailReceivingTokenFor:self.processDelegateTaskId];
}

- (void) userInfoSuccessCallback:(User *) enrichedUser {
    APPDELEGATE.session.user = enrichedUser;
    [delegate tokenManagerDidReceiveUserInfo];
}

- (void) userInfoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingUserInfo];
}

- (void) userInfoWithinProcessSuccessCallback:(User *) enrichedUser {
    APPDELEGATE.session.user = enrichedUser;
    [baseUrlWithinProcessDao requestBaseUrl];
}

- (void) userInfoWithinProcessFailCallback:(NSString *) errorMessage {
    [processDelegate tokenManagerWithinProcessDidFailReceivingTokenFor:self.processDelegateTaskId];
}

- (void) requestTokenWithinProcess:(int) taskId {
    self.processDelegateTaskId = taskId;
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi) {
        if([CacheUtil readRememberMeToken] != nil) {
            [tokenWithinProcessDao requestTokenByRememberMe];
        }
    } else if(networkStatus == kReachableViaWWAN) {
        [radiusWithinProcessDao requestRadiusLogin];
    }
}

- (void) requestConstants {
    [constantsDao requestConstants];
}

- (void) constantsSuccessCallback {
    [delegate tokenManagerDidReceiveConstants];
}

- (void) constantsFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingConstants];
}

@end

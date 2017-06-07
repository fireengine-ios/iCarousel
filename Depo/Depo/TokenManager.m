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
#import "AppUtil.h"
#import "CacheUtil.h"
#import "Reachability.h"

#import "RequestTokenDao.h"
#import "RequestBaseUrlDao.h"
#import "AccountInfoDao.h"
#import "RadiusDao.h"
#import "LogoutDao.h"
#import "ConstantsDao.h"
#import "EulaCheckDao.h"
#import "Util.h"

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
        
        eulaCheckDao = [[EulaCheckDao alloc] init];
        eulaCheckDao.delegate = self;
        eulaCheckDao.successMethod = @selector(eulaCheckSuccessCallback:);
        eulaCheckDao.failMethod = @selector(eulaCheckFailCallback:);
        
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

- (void) requestEulaCheck {
    [eulaCheckDao requestCheckEulaForLocale:[Util readLocaleCode]];
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
        [eulaCheckDao requestCheckEulaForLocale:[Util readLocaleCode]];
//        [delegate tokenManagerDidReceiveToken];
    }
}

- (void) tokenDaoFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidFailReceivingToken: errorMessage];
}

- (void) tokenWithinProcessDaoSuccessCallback {
//silent login'de account infoya gitmesin diye commentlendi 9.12.15
    //[userInfoWithinProcessDao requestAccountInfo];
    [baseUrlWithinProcessDao requestBaseUrl];
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
    [AppUtil increaseLoginCount];
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
    if([CacheUtil readRememberMeToken] != nil) {
        [tokenWithinProcessDao requestTokenByRememberMe];
    } else if(networkStatus == ReachableViaWWAN) {
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

- (void) eulaCheckSuccessCallback:(NSString *) statusVal {
    if(statusVal != nil && [statusVal isKindOfClass:[NSString class]]) {
        if([statusVal isEqualToString:@"EULA_APPROVE_REQUIRED"] ) {
            [delegate tokenManagerProvisionNeeded];
            return;
        }
    }
    [delegate tokenManagerDidReceiveToken];
}

- (void) eulaCheckFailCallback:(NSString *) errorMessage {
    [delegate tokenManagerDidReceiveToken];
}

@end

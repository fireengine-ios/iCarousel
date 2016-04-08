//
//  TokenManager.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestTokenDao;
@class RequestBaseUrlDao;
@class AccountInfoDao;
@class RadiusDao;
@class LogoutDao;
@class ConstantsDao;
@class EulaCheckDao;

@protocol TokenManagerDelegate <NSObject>
- (void) tokenManagerDidReceiveToken;
- (void) tokenManagerDidFailReceivingToken;
- (void) tokenManagerInadequateInfo;
- (void) tokenManagerDidReceiveBaseUrl;
- (void) tokenManagerDidFailReceivingBaseUrl;
- (void) tokenManagerDidReceiveConstants;
- (void) tokenManagerDidFailReceivingConstants;
- (void) tokenManagerDidReceiveUserInfo;
- (void) tokenManagerDidFailReceivingUserInfo;
- (void) tokenManagerProvisionNeeded;
- (void) tokenManagerMigrationInProgress;
@end

@protocol TokenManagerWithinProcessDelegate <NSObject>
- (void) tokenManagerWithinProcessDidReceiveTokenFor:(int) taskId;
- (void) tokenManagerWithinProcessDidFailReceivingTokenFor:(int) taskId;
@end

@interface TokenManager : NSObject {
    RequestTokenDao *tokenDao;
    RequestTokenDao *tokenWithinProcessDao;
    RequestBaseUrlDao *baseUrlDao;
    RequestBaseUrlDao *baseUrlWithinProcessDao;
    AccountInfoDao *userInfoDao;
    AccountInfoDao *userInfoWithinProcessDao;
    RadiusDao *radiusDao;
    RadiusDao *radiusWithinProcessDao;
    LogoutDao *logoutDao;
    ConstantsDao *constantsDao;
    EulaCheckDao *eulaCheckDao;
}

@property (nonatomic, strong) id<TokenManagerDelegate> delegate;
@property (nonatomic, strong) id<TokenManagerWithinProcessDelegate> processDelegate;

@property (nonatomic) int processDelegateTaskId;

- (void) requestRadiusLogin;
- (void) requestToken;
- (void) requestBaseUrl;
- (void) requestEulaCheck;
- (void) requestUserInfo;
- (void) requestLogout;
- (void) requestTokenByMsisdn:(NSString *) msisdn andPass:(NSString *) pass shouldRememberMe:(BOOL) rememberMeFlag;
- (void) requestTokenWithinProcess:(int) taskId;
- (void) requestConstants;

@end

//
//  TokenManager.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestTokenDao.h"
#import "RequestBaseUrlDao.h"
#import "AccountInfoDao.h"
#import "RadiusDao.h"
#import "LogoutDao.h"

@protocol TokenManagerDelegate <NSObject>
- (void) tokenManagerDidReceiveToken;
- (void) tokenManagerDidFailReceivingToken;
- (void) tokenManagerInadequateInfo;
- (void) tokenManagerDidReceiveBaseUrl;
- (void) tokenManagerDidFailReceivingBaseUrl;
- (void) tokenManagerDidReceiveUserInfo;
- (void) tokenManagerDidFailReceivingUserInfo;
- (void) tokenManagerProvisionNeeded;
- (void) tokenManagerMigrationInProgress;
@end

@interface TokenManager : NSObject {
    RequestTokenDao *tokenDao;
    RequestBaseUrlDao *baseUrlDao;
    AccountInfoDao *userInfoDao;
    RadiusDao *radiusDao;
    LogoutDao *logoutDao;
}

@property (nonatomic, strong) id<TokenManagerDelegate> delegate;

- (void) requestRadiusLogin;
- (void) requestToken;
- (void) requestBaseUrl;
- (void) requestUserInfo;
- (void) requestLogout;

@end

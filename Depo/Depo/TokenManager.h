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

@protocol TokenManagerDelegate <NSObject>
- (void) tokenManagerDidReceiveToken;
- (void) tokenManagerDidFailReceivingToken;
- (void) tokenManagerInadequateInfo;
- (void) tokenManagerDidReceiveBaseUrl;
- (void) tokenManagerDidFailReceivingBaseUrl;
@end

@interface TokenManager : NSObject {
    RequestTokenDao *tokenDao;
    RequestBaseUrlDao *baseUrlDao;
}

@property (nonatomic, strong) id<TokenManagerDelegate> delegate;

- (void) requestToken;
- (void) requestBaseUrl;

@end

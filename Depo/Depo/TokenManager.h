//
//  TokenManager.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestTokenDao.h"

@protocol TokenManagerDelegate <NSObject>
- (void) tokenManagerDidReceiveToken;
- (void) tokenManagerDidFailReceivingToken;
- (void) tokenManagerInadequateInfo;
@end

@interface TokenManager : NSObject {
    RequestTokenDao *tokenDao;
}

@property (nonatomic, strong) id<TokenManagerDelegate> delegate;

- (void) requestToken;

@end

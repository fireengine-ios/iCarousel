//
//  DropboxTokenDao.h
//  Depo
//
//  Created by Mahir Tarlan on 22/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface DropboxTokenDao : BaseDao

- (void) requestTokenWithCurrentToken:(NSString *) currentToken withConsumerKey:(NSString *) consumerKey withAppSecret:(NSString *) appSecret withAuthTokenSecret:(NSString *) authTokenSecret;

@end

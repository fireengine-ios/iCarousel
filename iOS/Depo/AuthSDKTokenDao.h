//
//  AuthSDKTokenDao.h
//  Depo
//
//  Created by Mahir on 09/11/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AuthSDKTokenDao : BaseDao

- (void) requestAuthSDKToken:(NSString *) token withRememberMeFlag:(BOOL) rememberMeFlag;

@end

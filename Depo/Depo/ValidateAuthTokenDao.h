//
//  ValidateAuthTokenDao.h
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface ValidateAuthTokenDao : BaseDao

- (void) requestAuthToken:(NSString *) token;

@end

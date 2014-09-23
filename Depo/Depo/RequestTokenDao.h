//
//  RequestTokenDao.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface RequestTokenDao : BaseDao

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal;

@end

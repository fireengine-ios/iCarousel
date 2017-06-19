//
//  FBConnectDao.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FBConnectDao : BaseDao

- (void) requestFbConnectWithToken:(NSString *) tokenVal;

@end

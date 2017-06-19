//
//  EulaApproveDao.h
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface EulaApproveDao : BaseDao

- (void) requestApproveEulaForId:(int) eulaId;

@end

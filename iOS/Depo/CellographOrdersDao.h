//
//  CellographOrdersDao.h
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface CellographOrdersDao : BaseDao

- (void) requestOrdersForId:(NSString *) cellographId;

@end

//
//  SearchByGroupDao.h
//  Depo
//
//  Created by Mahir Tarlan on 24/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface SearchByGroupDao : BaseDao

- (void) requestImagesByGroupByPage:(int) page bySize:(int) size byLevel:(int) level byGroupDate:(NSString *) groupDate byGroupSize:(NSNumber *) groupSize bySort:(SortType) sortType;

@end

//
//  SearchDao.h
//  Depo
//
//  Created by NCO on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface SearchDao : BaseDao {
    BOOL returnsList;
}

- (void) requestMetadata:(NSString *)text andPage:(int)page andSize:(int)size andSortType:(SortType)sortType andSearchListType:(int)searchListType;

@end

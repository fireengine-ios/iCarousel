//
//  ElasticSearchDao.h
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"
#import "AppConstants.h"

@interface ElasticSearchDao : BaseDao

- (void) requestPhotosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType;
- (void) requestMusicForPage:(int) page andSize:(int) size andSortType:(SortType) sortType;
- (void) requestDocForPage:(int) page andSize:(int) size andSortType:(SortType) sortType;

@end

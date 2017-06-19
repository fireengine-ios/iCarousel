//
//  AlbumListDao.h
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AlbumListDao : BaseDao

- (void) requestAlbumListForStart:(int) start andSize:(int) size;
- (void) requestAlbumListForStart:(int) start andSize:(int) size andSortType:(SortType) sortType;

@end

//
//  ElasticSearchDao.h
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface ElasticSearchDao : BaseDao

- (void) requestPhotosForPage:(int) page andSize:(int) size;

@end

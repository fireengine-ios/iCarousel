//
//  RecentActivitiesDao.h
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface RecentActivitiesDao : BaseDao

- (void) requestRecentActivitiesForPage:(int) page andCount:(int) count;

@end

//
//  DeleteDao.h
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface DeleteDao : BaseDao

- (void) requestDeleteFiles:(NSArray *) uuidList;

@end

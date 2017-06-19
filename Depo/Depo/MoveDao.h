//
//  MoveDao.h
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface MoveDao : BaseDao

- (void) requestMoveFiles:(NSArray *) fileList toFolder:(NSString *) folderUuid;

@end

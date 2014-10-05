//
//  AddFolderDao.h
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AddFolderDao : BaseDao

- (void) requestAddFolderAtPath:(NSString *) path;

@end

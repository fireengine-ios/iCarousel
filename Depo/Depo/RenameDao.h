//
//  RenameDao.h
//  Depo
//
//  Created by Mahir on 7.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface RenameDao : BaseDao

- (void) requestRenameForFile:(NSString *) uuid withNewName:(NSString *) newName;

@end

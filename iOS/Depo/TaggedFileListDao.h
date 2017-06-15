//
//  TaggedFileListDao.h
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface TaggedFileListDao : BaseDao

- (void) requestTaggedCellographFiles:(NSString *) tagVal;

@end

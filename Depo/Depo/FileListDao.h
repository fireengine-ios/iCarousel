//
//  FileListDao.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FileListDao : BaseDao

- (void) requestFileListingForParentForPage:(int) page andSize:(int) size sortBy:(SortType) sortType;
- (void) requestFileListingForFolder:(NSString *) folderUuid andForPage:(int) page andSize:(int) size sortBy:(SortType) sortType;

@end

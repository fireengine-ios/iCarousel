//
//  FileListDao.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FileListDao : BaseDao

- (void) requestFileListingForParentForOffset:(int) offset andSize:(int) size;
- (void) requestFileListingForFolder:(NSString *) folder andForOffset:(int) offset andSize:(int) size;
- (void) requestPhotosForOffset:(int) offset andSize:(int) size;

@end

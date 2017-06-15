//
//  AlbumDetailDao.h
//  Depo
//
//  Created by Mahir on 10/13/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AlbumDetailDao : BaseDao

- (void) requestDetailOfAlbum:(NSString *) albumUuid forStart:(int) page andSize:(int) size;

@end

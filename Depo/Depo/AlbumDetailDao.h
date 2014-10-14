//
//  AlbumDetailDao.h
//  Depo
//
//  Created by Mahir on 10/13/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AlbumDetailDao : BaseDao

- (void) requestDetailOfAlbum:(long) albumId forStart:(int) start andSize:(int) size;

@end

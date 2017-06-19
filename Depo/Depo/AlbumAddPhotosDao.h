//
//  AlbumAddPhotosDao.h
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AlbumAddPhotosDao : BaseDao

- (void) requestAddPhotos:(NSArray *) uuidList toAlbum:(NSString *) albumUuid;

@end

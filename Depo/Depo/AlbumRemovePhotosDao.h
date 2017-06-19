//
//  AlbumRemovePhotosDao.h
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface AlbumRemovePhotosDao : BaseDao

- (void) requestRemovePhotos:(NSArray *) uuidList fromAlbum:(NSString *) albumUuid;

@end

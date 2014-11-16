//
//  DeleteAlbumsDao.h
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface DeleteAlbumsDao : BaseDao

- (void) requestDeleteAlbums:(NSArray *) uuidList;

@end

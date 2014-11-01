//
//  FavoriteDao.h
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FavoriteDao : BaseDao

- (void) requestMetadataForFiles:(NSArray *) uuidList shouldFavorite:(BOOL) favoriteFlag;

@end

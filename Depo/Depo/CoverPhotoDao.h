//
//  CoverPhotoDao.h
//  Depo
//
//  Created by RDC Partner on 19/12/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface CoverPhotoDao : BaseDao

//- (void) requestDetailOfAlbum:(NSString *) albumUuid forStart:(int) page andSize:(int) size;
- (void) requestSetCoverPhoto:(NSString *) albumUuid coverPhoto:(NSString *) coverPhotoUuid;

@end

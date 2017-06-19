//
//  ProfilePhotoUploadDao.h
//  Depo
//
//  Created by Mahir Tarlan on 27/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface ProfilePhotoUploadDao : BaseDao

- (void) requestUploadForImage:(UIImage *) imageFile;

@end

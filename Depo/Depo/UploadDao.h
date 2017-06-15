//
//  UploadDao.h
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface UploadDao : BaseDao

- (void) requestUploadForFile:(ALAsset *) asset;

@end

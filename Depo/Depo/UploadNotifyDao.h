//
//  UploadNotifyDao.h
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface UploadNotifyDao : BaseDao

- (void) requestNotifyUploadForFile:(NSString *) fileContext;

@end

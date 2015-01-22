//
//  ShareLinkDao.h
//  Depo
//
//  Created by Mahir on 22/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface ShareLinkDao : BaseDao

- (void) requestLinkForFiles:(NSArray *) files;

@end

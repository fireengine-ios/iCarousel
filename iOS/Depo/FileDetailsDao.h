//
//  FileDetailsDao.h
//  Depo
//
//  Created by Mahir Tarlan on 25/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FileDetailsDao : BaseDao

- (void) requestFileDetails:(NSArray *) uuids;

@end

//
//  VideofyCreateDao.h
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"
#import "Story.h"

@interface VideofyCreateDao : BaseDao

- (void) requestVideofyCreateForStory:(Story *) story;

@end

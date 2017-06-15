//
//  ServiceLoginDao.h
//  Acdm_1
//
//  Created by mahir tarlan on 12/30/13.
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "BaseDao.h"

@interface ServiceLoginDao : BaseDao

- (void) requestServiceLogin:(NSString *) gsmVal withPass:(NSString *) passVal shouldRememberMe:(BOOL) rememberMe;

@end

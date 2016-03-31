//
//  EulaCheckDao.h
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface EulaCheckDao : BaseDao

- (void) requestCheckEulaForLocale:(NSString *) locale;

@end

//
//  DropboxConnectDao.h
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface DropboxConnectDao : BaseDao

- (void) requestConnectDropboxWithToken:(NSString *) tokenVal;

@end

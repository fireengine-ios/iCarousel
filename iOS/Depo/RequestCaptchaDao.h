//
//  RequestCaptchaDao.h
//  Depo
//
//  Created by Mahir on 19/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface RequestCaptchaDao : BaseDao

- (void) requestCaptchaForType:(NSString *) type andId:(NSString *) captchaId;

@end

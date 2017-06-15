//
//  ForgotPassDao.h
//  Depo
//
//  Created by Mahir on 19/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface ForgotPassDao : BaseDao

- (void) requestNotifyForgotPassWithEmail:(NSString *) email withCaptchaId:(NSString *) captchaId withCaptchaValue:(NSString *) captchaValue;

@end

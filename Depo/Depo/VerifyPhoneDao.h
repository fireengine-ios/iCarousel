//
//  VerifyPhoneDao.h
//  Depo
//
//  Created by Mahir on 07/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface VerifyPhoneDao : BaseDao

- (void) requestTriggerVerifyPhone:(NSString *) token withOTP:(NSString *) otp;

@end

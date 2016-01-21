//
//  SignupDao.h
//  Depo
//
//  Created by Mahir on 07/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface SignupDao : BaseDao

- (void) requestTriggerSignupForEmail:(NSString *) email forPhoneNumber:(NSString *) phoneNumber withPassword:(NSString *) password;

@end

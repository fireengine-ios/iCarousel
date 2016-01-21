//
//  SendVerificationSMSDao.h
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface SendVerificationSMSDao : BaseDao

- (void) requestTriggerSendVerificationSMS:(NSString *) token;

@end

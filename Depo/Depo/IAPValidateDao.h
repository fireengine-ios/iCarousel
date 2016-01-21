//
//  IAPValidateDao.h
//  Depo
//
//  Created by Mahir on 20/12/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface IAPValidateDao : BaseDao

- (void) requestIAPValidationForProductId:(NSString *) productId withReceiptId:(NSData *) receiptId;

@end

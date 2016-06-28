//
//  PromoCodeActivateDao.h
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface PromoCodeActivateDao : BaseDao

- (void) requestActivateCode:(NSString *) promoCode;

@end

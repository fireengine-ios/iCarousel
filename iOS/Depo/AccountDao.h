//
//  AccountDao.h
//  Depo
//
//  Created by Salih Topcu on 05.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "BaseDao.h"
#import "Offer.h"

typedef enum {
    RequestMethodGetCurrentSubscription = 0,
    RequestMethodGetActiveSubscriptions,
    RequestMethodGetOffers,
    RequestMethodActivateOffer,
    RequestMethodCancelSubscription,
    RequestMethodIsJobExists
} RequestMethod;

@interface AccountDao : BaseDao {
    int requestMethod;
}

- (void) requestCurrentAccount;
- (void) requestActiveSubscriptions;
- (void) requestOffers;
- (void) requestActivateOffer: (Offer *)offer;
//- (void) requestCancelSubscription: (Subscription *)subscription;
- (void) requestIsJobExists;

@end

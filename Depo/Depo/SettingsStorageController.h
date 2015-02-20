//
//  SettingsStorageController.h
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"
#import "AccountDao.h"

@interface SettingsStorageController : SettingsBaseViewController {
    AccountDao *accountDaoToGetCurrentSubscription;
    AccountDao *accountDaoToGetOffers;
    AccountDao *accountDaoToActivateOffer;
    Subscription *currentSubscription;
    NSMutableArray *offers;
    int tableUpdateCounter;
}

@end

//
//  SettingsStorageController.h
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"
#import "AccountDao.h"
#import "CustomConfirmView.h"

@interface SettingsStorageController : SettingsBaseViewController <CustomConfirmDelegate> {
    AccountDao *accountDaoToGetCurrentSubscription;
    AccountDao *accountDaoToGetOffers;
    AccountDao *accountDaoToActivateOffer;
    AccountDao *accountDaoToLearnIsJobExists;
    Subscription *currentSubscription;
    NSMutableArray *offers;
    int tableUpdateCounter;
    BOOL isJobExists;
    Offer *selectedOffer;
}

@end

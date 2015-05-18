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
#import "OfferRedesignCell.h"
#import "PurchaseView.h"

@interface SettingsStorageController : SettingsBaseViewController <CustomConfirmDelegate,OfferReDesignCellDelegate,PurchaseViewDelegate> {
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

@property (strong,nonatomic) PurchaseView *purchaseView ;
@property (strong,nonatomic) Subscription *offerToSubs;
@property (strong,nonatomic) NSArray *containerOffers;

@end

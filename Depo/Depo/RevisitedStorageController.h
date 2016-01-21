//
//  RevisitedStorageController.h
//  Depo
//
//  Created by Mahir on 13/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "AccountDao.h"
#import "CustomConfirmView.h"
#import "PurchaseView.h"
#import "IAPValidateDao.h"
#import "IAPManager.h"
#import "RevisitedCurrentSubscriptionCell.h"
#import "RevisitedOfferCell.h"
#import "AppleProductsListDao.h"

@interface RevisitedStorageController : MyViewController <CustomConfirmDelegate, PurchaseViewDelegate, IAPManagerDelegate, UITableViewDelegate, UITableViewDataSource, RevisitedCurrentSubscriptionCellDelegate, RevisitedOfferCellDelegate> {
    
    AccountDao *accountDaoToGetCurrentSubscription;
    AccountDao *accountDaoToGetOffers;
    AccountDao *accountDaoToActivateOffer;
    AccountDao *accountDaoToLearnIsJobExists;
    AppleProductsListDao *appleProductsDao;
    IAPValidateDao *iapValidateDao;
    
    NSArray *currentSubscriptions;
    NSArray *appleProductNames;
    NSMutableArray *offers;
    Offer *selectedOffer;

    int tableUpdateCounter;
    BOOL isJobExists;
}

@property (nonatomic, strong) UITableView *mainTable;
@property (strong,nonatomic) PurchaseView *purchaseView;

@end

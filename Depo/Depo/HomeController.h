//
//  HomeController.h
//  Depo
//
//  Created by Mahir on 9/19/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "RecentActivityLinkerFooter.h"
#import "HomeUsageView.h"
#import "Usage.h"
#import "UsageButton.h"
#import "SimpleButton.h"
#import "UsageInfoDao.h"
#import "ContactCountDao.h"
#import "AccountDao.h"
#import "OnkatDepoPopUP.h"
#import "CustomAdvertisementView.h"
#import "CustomConfirmView.h"
#import "QuotaInfoView.h"

@interface HomeController : MyViewController <RecentActivityLinkerDelegate, OnKatViewDeleagate,CustomAdvertisementDelegate, CustomConfirmDelegate> {
    UsageInfoDao *usageDao;
    ContactCountDao *contactCountDao;
    AccountDao *accountDao;
}

@property (nonatomic, strong) RecentActivityLinkerFooter *footer;
@property (nonatomic, strong) NSMutableArray *usages;
@property (nonatomic, strong) CustomLabel *lastSyncLabel;
@property (nonatomic, strong) QuotaInfoView *packageInfoView;
@property (nonatomic, strong) QuotaInfoView *quotaInfoView;
@property (nonatomic, strong) Usage *usage;
@property (nonatomic, strong) SimpleButton *moreStorageButton;
@property (nonatomic, strong) UsageButton *imageButton;
@property (nonatomic, strong) UsageButton *musicButton;
@property (nonatomic, strong) UsageButton *otherButton;
@property (nonatomic, strong) UsageButton *contactButton;
@property (nonatomic, strong) OnkatDepoPopUP *onkatView;
@property (nonatomic, strong) Subscription *currentSubscription;
@property (nonatomic, strong) CustomAdvertisementView *advertisementView;
@property (nonatomic, strong) UIView *packageContainer;
@property (nonatomic, strong) UIView *quotaContainer;

@end

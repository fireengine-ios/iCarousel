//
//  HomeController.m
//  Depo
//
//  Created by Mahir on 9/19/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "HomeController.h"
#import "MetaFile.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppUtil.h"
#import "SyncUtil.h"
#import "Usage.h"
#import "SettingsStorageController.h"
#import "RevisitedStorageController.h"

#import "FileListController.h"
#import "PhotoListController.h"
#import "DocListController.h"
#import "MusicListController.h"
#import "SettingsController.h"
#import "ContactSyncController.h"
#import "RecentActivitiesController.h"
#import "CurioSDK.h"
#import "Subscription.h"
#import "AppSession.h"
#import <SplunkMint/SplunkMint.h>
#import "EmailEntryController.h"
#import "MsisdnEntryController.h"
#import "MPush.h"
#import "GroupedPhotosAndVideosController.h"
#import "RevisitedGroupedPhotosController.h"
#import "QuotaInfoView.h"

#include <math.h>

@interface HomeController ()

@end

@implementation HomeController

@synthesize footer;
@synthesize usages;
@synthesize lastSyncLabel;
@synthesize usage;
@synthesize moreStorageButton;
@synthesize imageButton;
@synthesize musicButton;
@synthesize otherButton;
@synthesize contactButton;
@synthesize onkatView;
@synthesize currentSubscription;
@synthesize advertisementView;
@synthesize packageContainer;
@synthesize quotaContainer;
@synthesize packageInfoView;
@synthesize quotaInfoView;

- (id)init {
    self = [super init];
    if (self) {
        
        self.title = NSLocalizedString(@"UsageInfo", @"");
        
        
        usageDao = [[UsageInfoDao alloc] init];
        usageDao.delegate = self;
        usageDao.successMethod = @selector(usageSuccessCallback:);
        usageDao.failMethod = @selector(usageFailCallback:);
        
        accountDao = [[AccountDao alloc] init];
        accountDao.delegate = self;
        accountDao.successMethod = @selector(accountSuccessCallback:);
        accountDao.failMethod = @selector(accountFailCallback:);

        /* contactCountSuccessCallback
        contactCountDao = [[ContactCountDao alloc] init];
        contactCountDao.delegate = self;
        contactCountDao.successMethod = @selector(contactCountSuccessCallback:);
        contactCountDao.failMethod = @selector(contactCountFailCallback:);
        
         
        float footerHeight = 60;
        float footerYIndex = self.view.frame.size.height - 124;
        if(IS_IPAD) {
            footerHeight = 100;
            footerYIndex = self.view.frame.size.height - 164;
        }
        footer = [[RecentActivityLinkerFooter alloc] initWithFrame:CGRectMake(0, footerYIndex, self.view.frame.size.width, footerHeight)];
        footer.delegate = self;
        [self.view addSubview:footer];
         */
        
        [usageDao requestUsageInfo];
        [self showLoading];
        
        [accountDao requestActiveSubscriptions];
    }
    return self;
}

#pragma mark RecentActivityLinker Method

- (void) recentActivityLinkerDidTriggerPage {
    [MoreMenuView presentRecentActivitesFromController:self.nav];
}

- (void) usageSuccessCallback:(Usage *) _usage {
    [self hideLoading];
    APPDELEGATE.session.usage = _usage;
    
    double percentUsageVal = 0;
    if(APPDELEGATE.session.usage.totalStorage > 0) {
        percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);
    }

    float remainingStorage = APPDELEGATE.session.usage.totalStorage - APPDELEGATE.session.usage.usedStorage;
    
    
    [packageInfoView removeFromSuperview];
    [quotaInfoView removeFromSuperview];
    [self drawPackageSection:APPDELEGATE.session.usage];
    
    moreStorageButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150)/2, quotaInfoView.frame.origin.y + quotaInfoView.frame.size.height + (IS_IPAD ? 50 : IS_IPHONE_5 ? 20 : 0), 150, 44) withTitle:NSLocalizedString(@"GetMoreStorageButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:22];
    moreStorageButton.hidden = YES;
    [moreStorageButton addTarget:self action:@selector(triggerStoragePage) forControlEvents:UIControlEventTouchUpInside];
    moreStorageButton.isAccessibilityElement = YES;
    moreStorageButton.accessibilityIdentifier = @"moreStorageButtonHome";
    [self.view addSubview:moreStorageButton];
    

    self.usages = [NSMutableArray arrayWithCapacity:5];
    [usages addObject:[NSNumber numberWithLongLong:(APPDELEGATE.session.usage.imageUsage + APPDELEGATE.session.usage.videoUsage)]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.musicUsage]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.otherUsage]];
    [usages addObject:[NSNumber numberWithLongLong:0ll]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.remainingStorage]];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, moreStorageButton.frame.origin.y + moreStorageButton.frame.size.height + (IS_IPAD ? 50 : IS_IPHONE_4_OR_LESS ? 10: 20), self.view.frame.size.width - 40, 1)];
    separator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
    separator.isAccessibilityElement = YES;
    separator.accessibilityIdentifier = @"separatorHome";
    [self.view addSubview:separator];
    
    CGRect musicRect = CGRectMake(0, separator.frame.origin.y + (IS_IPHONE_4_OR_LESS ? 11 : 41), 75, 60);
    musicRect.origin.x = self.view.center.x - musicRect.size.width/2;
    
    CGRect imageRect = CGRectMake(0, separator.frame.origin.y + (IS_IPHONE_4_OR_LESS ? 11 : 41), 75, 60);
    imageRect.origin.x = musicRect.origin.x - 20 - musicRect.size.width;
    
    CGRect otherRect = CGRectMake(0, separator.frame.origin.y + (IS_IPHONE_4_OR_LESS ? 11 : 41), 75, 60);
    otherRect.origin.x = musicRect.origin.x + 20 + musicRect.size.width;

    if(IS_IPAD) {
        float leftMarginForIpad = 100;
        float buttonSliceWidth = (self.view.frame.size.width - (leftMarginForIpad*2))/3;
        
        imageRect = CGRectMake(leftMarginForIpad, separator.frame.origin.y + 51, buttonSliceWidth, 100);
        musicRect = CGRectMake(self.view.frame.size.width/2 - buttonSliceWidth/2, separator.frame.origin.y + 51, buttonSliceWidth, 100);
        otherRect = CGRectMake(self.view.frame.size.width - leftMarginForIpad - buttonSliceWidth, separator.frame.origin.y + 51, buttonSliceWidth, 100);
    }
    
    imageButton = [[UsageButton alloc] initWithFrame:imageRect withUsage:UsageTypeImage withStorage:(APPDELEGATE.session.usage.imageUsage + APPDELEGATE.session.usage.videoUsage) withFileCount:(APPDELEGATE.session.usage.imageCount + APPDELEGATE.session.usage.videoCount)];
    [imageButton addTarget:self action:@selector(triggerPhotosPage) forControlEvents:UIControlEventTouchUpInside];
    imageButton.isAccessibilityElement = YES;
    imageButton.accessibilityIdentifier = @"imageButtonHome";
    [self.view addSubview:imageButton];
    
    musicButton = [[UsageButton alloc] initWithFrame:musicRect withUsage:UsageTypeMusic withStorage:APPDELEGATE.session.usage.musicUsage withFileCount:APPDELEGATE.session.usage.audioCount];
    [musicButton addTarget:self action:@selector(triggerMusicPage) forControlEvents:UIControlEventTouchUpInside];
    musicButton.isAccessibilityElement = YES;
    musicButton.accessibilityIdentifier = @"musicButtonHome";
    [self.view addSubview:musicButton];
    
    otherButton = [[UsageButton alloc] initWithFrame:otherRect withUsage:UsageTypeOther withStorage:APPDELEGATE.session.usage.otherUsage withFileCount:APPDELEGATE.session.usage.othersCount];
    [otherButton addTarget:self action:@selector(triggerDocsPage) forControlEvents:UIControlEventTouchUpInside];
    otherButton.isAccessibilityElement = YES;
    otherButton.accessibilityIdentifier = @"otherButtonHome";
    [self.view addSubview:otherButton];
    
    /* contacts commented out
    contactButton = [[UsageButton alloc] initWithFrame:CGRectMake(230, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeContact withCountValue:@""];
    [contactButton addTarget:self action:@selector(triggerContactsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactButton];
     */

    if(percentUsageVal >= 80) {
        moreStorageButton.hidden = NO;
        
        if(!APPDELEGATE.session.quotaExceed80EventFlag) {
            //session basina bu event bir kere gönderilsin kontrolü eklendi
            [[CurioSDK shared] sendEvent:@"quota_exceeded_80_perc" eventValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            [MPush hitTag:@"quota_exceeded_80_perc" withValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            APPDELEGATE.session.quotaExceed80EventFlag = YES;
        }
    }

    if(APPDELEGATE.session.usage.totalStorage > 0 && remainingStorage <= 5242880) {
        if(![AppUtil readDoNotShowAgainFlagForKey:@"QUOTA_FULL_DONTSHOW_DEFAULTS_KEY"] && !APPDELEGATE.session.storageFullPopupShown) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"PackageFullMaessage", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:@"QUOTA_FULL_DONTSHOW_DEFAULTS_KEY"];
            confirm.delegate = self;
            confirm.tag = 222;
            confirm.isAccessibilityElement = YES;
            confirm.accessibilityIdentifier = @"customConfirmViewHome";
            [APPDELEGATE showCustomConfirm:confirm];
            APPDELEGATE.session.storageFullPopupShown = YES;
        }
    }

    
// contacts commented out //    [contactCountDao requestContactCount];
}

- (void) usageFailCallback:(NSString *) errorMessage {
    [self hideLoading];
//TODO check    [self showErrorAlertWithMessage:errorMessage];
}

- (void) triggerStoragePage {
    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:NO];
}

- (void) triggerFilesPage {
    FileListController *file = [[FileListController alloc] initForFolder:nil];
    file.nav = self.nav;
    [self.nav pushViewController:file animated:NO];
}

- (void) triggerPhotosPage {
//    GroupedPhotosAndVideosController *photo = [[GroupedPhotosAndVideosController alloc] init];
    RevisitedGroupedPhotosController *photo = [[RevisitedGroupedPhotosController alloc] init];
    photo.nav = self.nav;
    [self.nav pushViewController:photo animated:NO];
}

- (void) triggerContactsPage {
    ContactSyncController *contact = [[ContactSyncController alloc] init];
    contact.nav = self.nav;
    [self.nav pushViewController:contact animated:NO];
}

- (void) triggerMusicPage {
    MusicListController *music = [[MusicListController alloc] init];
    music.nav = self.nav;
    [self.nav pushViewController:music animated:NO];
}

- (void) triggerDocsPage {
    DocListController *doc = [[DocListController alloc] init];
    doc.nav = self.nav;
    [self.nav pushViewController:doc animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [APPDELEGATE.base dismissAddButton];
}

- (void) contactCountSuccessCallback:(NSString *) contactVal {
    [contactButton updateCountValue:contactVal];
}

- (void) contactCountFailCallback:(NSString *) errorMessage {
    [contactButton updateCountValue:[NSString stringWithFormat:@"%d", 0]];
}

- (void) accountSuccessCallback:(NSArray *) subscriptions {
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"onKatViewFlag"]){
        if([subscriptions count] > 0) {
            //TODO ilk subscription'a bakiyor, bu düzeltilecek
            currentSubscription = [subscriptions objectAtIndex:0];
            [self flowChartAdvertising];
            
//            for(Subscription *subsc in subscriptions) {
//                if(subsc.plan != nil && subsc.plan.cometOfferId != nil) {
//                    if(subsc.plan.cometOfferId.intValue == 581814) {
//                        [MPush hitTag:@"platin_user"];
//                    }
//                }
//            }
//            
//            if(APPDELEGATE.session.user.accountType == AccountTypeTurkcell) {
//                BOOL hasAnyTurkcellPackage = NO;
//                for(Subscription *subscription in subscriptions) {
//                    if(!subscription.type || !([subscription.type isEqualToString:@"INAPP_PURCHASE_GOOGLE"] || [subscription.type isEqualToString:@"INAPP_PURCHASE_APPLE"])) {
//                        hasAnyTurkcellPackage = YES;
//                    }
//                }
//                if(!hasAnyTurkcellPackage) {
//                    if(![AppUtil readDoNotShowAgainFlagForKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"]) {
//                        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"PortinInfoMessage", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"];
//                        confirm.delegate = self;
//                        confirm.tag = 333;
//                        [APPDELEGATE showCustomConfirm:confirm];
//                    }
//                }
//            }
        }
    }
    int counter = 1;
    for(Subscription *subsc in subscriptions) {
        if(subsc.plan != nil && subsc.plan.displayName != nil) {
            NSString *tagName = [NSString stringWithFormat:@"user_package_%d", counter];
            [MPush hitTag:tagName withValue:subsc.plan.displayName];
            counter ++;
        }
    }
}


#pragma mark FlowChart Actions

- (void) checkCurrentPackageIsChange {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentPackageInfo"]) {
        NSString *package = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentPackageInfo"];
        if (![currentSubscription.plan.role isEqualToString:package]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIALOGUE_P4_FLAG];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIALOGUE_P5_FLAG];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIALOGUE_P6_FLAG];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:currentSubscription.plan.role forKey:@"currentPackageInfo"];
    }
}

- (void) flowChartAdvertising {
    
    double percentUsageVal = 0;
    if(APPDELEGATE.session.usage.totalStorage > 0) {
        percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);
    }
    
    NSString *eventValue = nil;
    if(percentUsageVal >= 100) {
        eventValue = @"quota_full";
    } else if(percentUsageVal >= 99.0) {
        eventValue = @"quota_99_percent_full";
    } else if(percentUsageVal >= 90.0) {
        eventValue = @"quota_90_percent_full";
    } else if(percentUsageVal >= 80.0) {
        eventValue = @"quota_80_percent_full";
    }
    if(eventValue) {
        [MPush hitEvent:eventValue];
    }
    if(!isnan(percentUsageVal)) {
        [MPush hitTag:@"quota_status" withValue:[NSString stringWithFormat:@"%.0f", percentUsageVal]];
    }
    
    if(APPDELEGATE.session.usage.totalStorage > 0) {
        if(APPDELEGATE.session.usage.totalStorage - APPDELEGATE.session.usage.usedStorage <= 5242880) {
            [MPush hitTag:@"quota_5_mb_left"];
        }
    }

    if (APPDELEGATE.session.newUserFlag) {
        if (currentSubscription.plan.cometOfferId.intValue == 581803) {
            if ( [AppUtil checkAndSetFlags:DIALOGUE_P1_FLAG]) {
                [self loadAdvertisementView:NSLocalizedString(@"WelcomePackage1GB", @"") withOption:NO withTitle:nil];
            }
        } else if (currentSubscription.plan.cometOfferId.intValue == 581814){
            if ([AppUtil checkAndSetFlags:DIALOGUE_P2_FLAG]) {
                [self loadAdvertisementView:NSLocalizedString(@"PlatinPackage500GB", @"") withOption:NO withTitle:NSLocalizedString(@"PlatinPackage500GBTitle", @"")];
            }
        } else if (currentSubscription.plan.slcmOfferId.intValue == 603505139){
            if ([AppUtil checkAndSetFlags:DIALOGUE_P3_FLAG]) {
                [self loadAdvertisementView:NSLocalizedString(@"TurkcellPhone5GB", @"") withOption:NO withTitle:nil];
            }
        }
    } else {
        if (APPDELEGATE.session.migrationUserFlag && ![currentSubscription.plan.role isEqualToString:@"demo"]) {
            if ([AppUtil checkAndSetFlags:DIALOGUE_P8_FLAG]) {
                if ([self shouldShowOnKatView:currentSubscription]) {
                    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
                    onkatView = [[OnkatDepoPopUP alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height)];
                    onkatView.delegate = self;
                    onkatView.isAccessibilityElement = YES;
                    onkatView.accessibilityIdentifier = @"onkatViewHome";
                    [currentWindow addSubview:onkatView];
                }
                
            }
        } else {
            if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
                //no action for now
            } else {
                if (percentUsageVal >= 100 && [AppUtil checkAndSetFlags:DIALOGUE_P6_FLAG] ){
                    [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG];
                    [AppUtil checkAndSetFlags:DIALOGUE_P4_FLAG];
                    [self loadAdvertiesementViewFullMessage:NSLocalizedString(@"StorageFull100", @"") isFull:YES withTitle:NSLocalizedString(@"StorageFull100Title", @"")];
                } else if (percentUsageVal >= 90 && [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG]){
                    [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG];
                    [self loadAdvertisementView:NSLocalizedString(@"StorageOver90", @"") withOption:YES withTitle:NSLocalizedString(@"StorageOver90Title", @"")];
                } else if (percentUsageVal >= 80 && [AppUtil checkAndSetFlags:DIALOGUE_P4_FLAG]){
                    [self loadAdvertisementView:NSLocalizedString(@"StorageOver80", @"") withOption:YES withTitle:NSLocalizedString(@"StorageOver80Title", @"")];
                }
            }
        }
    }
}

- (BOOL) shouldShowOnKatView:(Subscription *) subscription {
    if (![subscription.plan.role isEqualToString:@"demo"] ) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onKatViewFlag"];
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)getPackageDisplayName: (NSString *)roleName {
    NSString *name = @"";
    if ([roleName isEqualToString:@"demo"]) {
        name = NSLocalizedString(@"Welcome", @"");
    } else if ([roleName isEqualToString:@"standard"]) {
        name = @"MINI PAKET";
    } else if ([roleName isEqualToString:@"premium"]) {
        name = @"STANDARD PAKET";
    } else if ([roleName isEqualToString:@"ultimate"]) {
        name = @"MEGA PAKET";
    }
    return name;
}


- (void) accountFailCallback:(NSString *) errorMessage{
}

- (void) dismissOnKatView {
    [onkatView removeFromSuperview];
}

- (void) loadAdvertisementView:(NSString *) message withOption:(BOOL) option withTitle:(NSString *) title{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    advertisementView = [[CustomAdvertisementView alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height) withMessage:message withBooleanOption:option withTitle:title];
    advertisementView.delegate = self;
    advertisementView.isAccessibilityElement = YES;
    advertisementView.accessibilityIdentifier = @"advertisementViewHome";
    [currentWindow addSubview:advertisementView];
}

- (void) loadAdvertiesementViewFullMessage: (NSString *) message isFull:(BOOL) isFull withTitle:(NSString *) title {
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    advertisementView = [[CustomAdvertisementView alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height) withMessage:message withFullPackage:YES withTitle:title];
    advertisementView.delegate = self;
    advertisementView.isAccessibilityElement = YES;
    advertisementView.accessibilityIdentifier = @"advertisementViewMessageHome";
    [currentWindow addSubview:advertisementView];
}

- (void) advertisementViewNoClick {
    [advertisementView removeFromSuperview];
    
}

- (void) advertisementViewOkClick {
    [advertisementView removeFromSuperview];
}

- (void) advertisementViewYesClick {
    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
    [advertisementView removeFromSuperview];
}

- (void) advertisementViewOkClickWhenFull {
    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
    [advertisementView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CurioSDK shared] sendEvent:@"Home" eventValue:@"shown"];
    [MPush hitTag:@"Home" withValue:@"shown"];
    IGLog(@"HomeController viewDidLoad");
    //BugSense'e msisdn ekleyebilmek için burada initialize ediyoruz
    if([CacheUtil readCachedMsisdnForPostMigration] != nil){
        [[Mint sharedInstance] setUserIdentifier:[CacheUtil readCachedMsisdnForPostMigration]];
    }
    [[Mint sharedInstance] initAndStartSession:@"13ceffcf"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
    if(alertView.tag == 111) {
//        [[CurioSDK shared] sendEvent:@"EmailEmpty" eventValue:@"Later"];
//        [[CurioSDK shared] sendEvent:@"EmailConfirm" eventValue:@"later"];
//        [MPush hitTag:@"EmailEmpty" withValue:@"Later"];
//        [MPush hitTag:@"EmailConfirm" withValue:@"later"];
    }
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    if(alertView.tag == 111) {
//        [[CurioSDK shared] sendEvent:@"EmailEmpty" eventValue:@"Enter"];
//        [[CurioSDK shared] sendEvent:@"EmailConfirm" eventValue:@"ok"];
//        [MPush hitTag:@"EmailEmpty" withValue:@"Enter"];
//        [MPush hitTag:@"EmailConfirm" withValue:@"ok"];
//        EmailEntryController *emailController = [[EmailEntryController alloc] init];
//        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:emailController];
//        [self presentViewController:modalNav animated:YES completion:nil];
    } else if(alertView.tag == 222 || alertView.tag == 333) {
        RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
        storageController.nav = self.nav;
        [self.nav pushViewController:storageController animated:NO];
    }
}

- (void) cancelRequests {
    [usageDao cancelRequest];
    usageDao = nil;

    [accountDao cancelRequest];
    accountDao = nil;
}

- (void) drawPackageSection:(Usage *) packageUsage {
    
    UIView *separator;
    
    if(packageUsage.internetDataUsage != nil && ![packageUsage.internetDataUsage isKindOfClass:[NSNull class]]) {
        packageInfoView = [[QuotaInfoView alloc] initWithFrame:CGRectMake(20, 30, self.view.frame.size.width - 40, 85) withTitle:@"4.5G Lifebox Standart Internet" withUsage:packageUsage withControllerView:self.view showInternetData:YES];
        [self.view addSubview:packageInfoView];
        
        //Container Separator
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(20, packageInfoView.frame.origin.y + packageInfoView.frame.size.height + (IS_IPAD ? 50 : IS_IPHONE_4_OR_LESS ? 10: 32), self.view.frame.size.width - 40, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
        [self.view addSubview:separator];
    }
    
    quotaInfoView = [[QuotaInfoView alloc] initWithFrame:CGRectMake(20, separator.frame.origin.y + 30, self.view.frame.size.width - 40, 85) withTitle:NSLocalizedString(@"QuotaInfoTitle", @"") withUsage:packageUsage withControllerView:self.view showInternetData:NO];
    [self.view addSubview:quotaInfoView];
}

@end

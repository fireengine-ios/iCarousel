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
#import "CurioSDK.h"
#import "Subscription.h"
#import "AppSession.h"
#import <SplunkMint/SplunkMint.h>
#import "EmailEntryController.h"
#import "MsisdnEntryController.h"
#import "MPush.h"
#import "GroupedPhotosAndVideosController.h"
#import "RevisitedGroupedPhotosController.h"

@interface HomeController ()

@end

@implementation HomeController

@synthesize footer;
@synthesize usageChart;
@synthesize usages;
@synthesize usageColors;
@synthesize lastSyncLabel;
@synthesize percentLabel;
@synthesize usageSummaryView;
@synthesize usage;
@synthesize moreStorageButton;
@synthesize imageButton;
@synthesize musicButton;
@synthesize otherButton;
@synthesize contactButton;
@synthesize onkatView;
@synthesize currentSubscription;
@synthesize advertisementView;

- (id)init {
    self = [super init];
    if (self) {
        UIImageView *imgForTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
        imgForTitle.image = [UIImage imageNamed:@"cloud_icon.png"];
        self.navigationItem.titleView = imgForTitle;
        
        CustomButton *customSettingsButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"settings_icon"];
        [customSettingsButton addTarget:self action:@selector(triggerSettingsPage) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:customSettingsButton];
        self.navigationItem.rightBarButtonItem = settingsButton;
        
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
        */
        
        float chartWidth = 200;
        float labelRadius = 40;
        if(IS_IPAD) {
            chartWidth = self.view.frame.size.width - 300;
            labelRadius = 150;
        }
        usageChart = [[XYPieChart alloc] initWithFrame:[self usageChartFrame]];
        usageChart.dataSource = self;
        usageChart.startPieAngle = M_PI_2;
        usageChart.animationSpeed = 1.0;
        usageChart.labelFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:24];
        usageChart.labelRadius = labelRadius;
        usageChart.showLabel = NO;
        usageChart.showPercentage = NO;
        usageChart.pieBackgroundColor = [UIColor whiteColor];
        usageChart.pieCenter = CGPointMake(chartWidth/2, chartWidth/2);
        usageChart.userInteractionEnabled = NO;
        usageChart.labelShadowColor = [UIColor blackColor];
        [self.view addSubview:usageChart];

        NSString *lastSyncTitle = @"";
        if([SyncUtil readLastSyncDate] != nil) {
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"LastSyncFormat", @""), [AppUtil readDueDateInReadableFormat:[SyncUtil readLastSyncDate]]];
        }
        lastSyncLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, IS_IPHONE_5 ? 18 : 8, self.view.frame.size.width - 40, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:lastSyncTitle withAlignment:NSTextAlignmentCenter];
        //[self.view addSubview:lastSyncLabel];
        
        moreStorageButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150)/2, usageChart.frame.origin.y + usageChart.frame.size.height + (IS_IPAD ? 50 : IS_IPHONE_5 ? 20 : 0), 150, 44) withTitle:NSLocalizedString(@"GetMoreStorageButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:22];
        moreStorageButton.hidden = YES;
        [moreStorageButton addTarget:self action:@selector(triggerStoragePage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreStorageButton];
        
        /*
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

- (CGRect) usageChartFrame {
    float chartWidth = 200;
    CGRect usageChartRect = CGRectMake(60, IS_IPHONE_5 ? 40 : 26, chartWidth, chartWidth);
    if(IS_IPAD) {
        chartWidth = self.view.frame.size.width - 300;
        usageChartRect = CGRectMake(150, 50, chartWidth, chartWidth);
    }
    return usageChartRect;
}

#pragma mark RecentActivityLinker Method

- (void) recentActivityLinkerDidTriggerPage {
    [APPDELEGATE.base showRecentActivities];
}

- (void) tempDraw {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, 100, 100, 50, 0, 30, 1);
    CGContextSetRGBFillColor(context, 1, 0.5, 0.5, 1.0);
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return self.usages.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    long long sliceUsage = [[self.usages objectAtIndex:index] longLongValue];
    
    if(sliceUsage > 0.0l) {
        float totalStorage5Percent = APPDELEGATE.session.usage.totalStorage/20;
        if(sliceUsage < totalStorage5Percent) {
            sliceUsage = totalStorage5Percent;
        }
    }
    return sliceUsage;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.usageColors objectAtIndex:(index % self.usageColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
}

- (void) usageSuccessCallback:(Usage *) _usage {
    [self hideLoading];
    APPDELEGATE.session.usage = _usage;
    
    double percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);

    float remainingStorage = APPDELEGATE.session.usage.totalStorage - APPDELEGATE.session.usage.usedStorage;

    self.usages = [NSMutableArray arrayWithCapacity:5];
    [usages addObject:[NSNumber numberWithLongLong:(APPDELEGATE.session.usage.imageUsage + APPDELEGATE.session.usage.videoUsage)]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.musicUsage]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.otherUsage]];
    [usages addObject:[NSNumber numberWithLongLong:0ll]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.remainingStorage]];
    
    self.usageColors =[NSArray arrayWithObjects:
                       [Util UIColorForHexColor:@"fcd02b"],
                       [Util UIColorForHexColor:@"84c9b7"],
                       [Util UIColorForHexColor:@"579fb2"],
                       [Util UIColorForHexColor:@"ec6453"],
                       [Util UIColorForHexColor:@"e8e9e8"], nil];

    [usageChart reloadData];
    
    CGRect usageSummaryRect = CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130);
    if(IS_IPAD) {
        usageSummaryRect = CGRectMake(80, 80, usageChart.frame.size.width - 160, usageChart.frame.size.width - 160);
    }
    usageSummaryView = [[HomeUsageView alloc] initWithFrame:usageSummaryRect withUsage:APPDELEGATE.session.usage];
    [usageChart addSubview:usageSummaryView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, moreStorageButton.frame.origin.y + moreStorageButton.frame.size.height + (IS_IPAD ? 50 : IS_IPHONE_5 ? 20: 5), self.view.frame.size.width - 40, 1)];
    separator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
    [self.view addSubview:separator];
    
    CGRect imageRect = CGRectMake(20, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60);
    CGRect musicRect = CGRectMake(122, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60);
    CGRect otherRect = CGRectMake(225, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60);
    
    if(IS_IPAD) {
        float leftMarginForIpad = 100;
        float buttonSliceWidth = (self.view.frame.size.width - (leftMarginForIpad*2))/3;
        
        imageRect = CGRectMake(leftMarginForIpad, separator.frame.origin.y + 51, buttonSliceWidth, 100);
        musicRect = CGRectMake(self.view.frame.size.width/2 - buttonSliceWidth/2, separator.frame.origin.y + 51, buttonSliceWidth, 100);
        otherRect = CGRectMake(self.view.frame.size.width - leftMarginForIpad - buttonSliceWidth, separator.frame.origin.y + 51, buttonSliceWidth, 100);
    }
    
    imageButton = [[UsageButton alloc] initWithFrame:imageRect withUsage:UsageTypeImage withStorage:(APPDELEGATE.session.usage.imageUsage + APPDELEGATE.session.usage.videoUsage) withFileCount:(APPDELEGATE.session.usage.imageCount + APPDELEGATE.session.usage.videoCount)];
    [imageButton addTarget:self action:@selector(triggerPhotosPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    musicButton = [[UsageButton alloc] initWithFrame:musicRect withUsage:UsageTypeMusic withStorage:APPDELEGATE.session.usage.musicUsage withFileCount:APPDELEGATE.session.usage.audioCount];
    [musicButton addTarget:self action:@selector(triggerMusicPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    otherButton = [[UsageButton alloc] initWithFrame:otherRect withUsage:UsageTypeOther withStorage:APPDELEGATE.session.usage.otherUsage withFileCount:APPDELEGATE.session.usage.othersCount];
    [otherButton addTarget:self action:@selector(triggerDocsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
    
    /* contacts commented out
    contactButton = [[UsageButton alloc] initWithFrame:CGRectMake(230, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeContact withCountValue:@""];
    [contactButton addTarget:self action:@selector(triggerContactsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactButton];
     */

    if(percentUsageVal >= 80) {
        moreStorageButton.hidden = NO;
        CGRect currentChartFrame = [self usageChartFrame];
        usageChart.frame = CGRectMake(currentChartFrame.origin.x, currentChartFrame.origin.y + lastSyncLabel.frame.size.height, currentChartFrame.size.width, currentChartFrame.size.height);
        
        CGRect usageSummaryRect = CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130);
        if(IS_IPAD) {
            usageSummaryRect = CGRectMake(80, 80, usageChart.frame.size.width - 160, usageChart.frame.size.width - 160);
        }
        usageSummaryView.frame = usageSummaryRect;
        if(!APPDELEGATE.session.quotaExceed80EventFlag) {
            //session basina bu event bir kere gönderilsin kontrolü eklendi
            [[CurioSDK shared] sendEvent:@"quota_exceeded_80_perc" eventValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            [MPush hitTag:@"quota_exceeded_80_perc" withValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
            APPDELEGATE.session.quotaExceed80EventFlag = YES;
        }
    } else {
        CGRect currentChartFrame = [self usageChartFrame];
        usageChart.frame = CGRectMake(currentChartFrame.origin.x, currentChartFrame.origin.y + lastSyncLabel.frame.size.height, currentChartFrame.size.width, currentChartFrame.size.height);
        
        CGRect usageSummaryRect = CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130);
        if(IS_IPAD) {
            usageSummaryRect = CGRectMake(80, 80, usageChart.frame.size.width - 160, usageChart.frame.size.width - 160);
        }
        usageSummaryView.frame = usageSummaryRect;
    }

    if(remainingStorage <= 5242880) {
        if(![AppUtil readDoNotShowAgainFlagForKey:@"QUOTA_FULL_DONTSHOW_DEFAULTS_KEY"] && !APPDELEGATE.session.storageFullPopupShown) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"PackageFullMaessage", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:@"QUOTA_FULL_DONTSHOW_DEFAULTS_KEY"];
            confirm.delegate = self;
            confirm.tag = 222;
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

- (void) triggerSettingsPage {
    SettingsController *settings = [[SettingsController alloc] init];
    settings.nav = self.nav;
    [self.nav pushViewController:settings animated:NO];
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
    //TODO düzelt
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
    if(usageChart) {
        [usageChart reloadData];
    }
//    [self performSelector:@selector(tempDraw) withObject:nil afterDelay:2.0f];
}

- (void) contactCountSuccessCallback:(NSString *) contactVal {
    [contactButton updateCountValue:contactVal];
}

- (void) contactCountFailCallback:(NSString *) errorMessage {
    [contactButton updateCountValue:[NSString stringWithFormat:@"%d", 0]];
}

- (void) accountSuccessCallback:(NSArray *) subscriptions {
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"onKatViewFlag"]){
        if(APPDELEGATE.session.msisdnEmpty) {
            MsisdnEntryController *msisdnController = [[MsisdnEntryController alloc] init];
            MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:msisdnController];
            [self presentViewController:modalNav animated:YES completion:nil];
            
            //        [APPDELEGATE triggerLogout];
            //        [self showErrorAlertWithMessage:NSLocalizedString(@"MsisdnEmpty", @"")];
            //        return;
        }
        
        if(APPDELEGATE.session.emailEmpty && !APPDELEGATE.session.emailEmptyMessageShown && ![AppUtil readDoNotShowAgainFlagForKey:EMPTY_EMAIL_CONFIRM_KEY]) {
            APPDELEGATE.session.emailEmptyMessageShown = YES;
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"EmailEmpty", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:EMPTY_EMAIL_CONFIRM_KEY];
            confirm.delegate = self;
            confirm.tag = 111;
            [APPDELEGATE showCustomConfirm:confirm];
        } else if(APPDELEGATE.session.emailNotVerified && !APPDELEGATE.session.emailNotVerifiedMessageShown) {
            APPDELEGATE.session.emailNotVerifiedMessageShown = YES;
            [self showInfoAlertWithMessage:NSLocalizedString(@"EmailNotVerified", @"")];
        } else if([subscriptions count] > 0) {
            //TODO ilk subscription'a bakiyor, bu düzeltilecek
            currentSubscription = [subscriptions objectAtIndex:0];
            [self flowChartAdvertising];
            
            for(Subscription *subsc in subscriptions) {
                if(subsc.plan != nil && subsc.plan.cometOfferId != nil) {
                    if(subsc.plan.cometOfferId.intValue == 581814) {
                        [MPush hitTag:@"platin_user"];
                    }
                }
            }
            
            if(APPDELEGATE.session.user.accountType == AccountTypeTurkcell) {
                BOOL hasAnyTurkcellPackage = NO;
                for(Subscription *subscription in subscriptions) {
                    if(!subscription.type || !([subscription.type isEqualToString:@"INAPP_PURCHASE_GOOGLE"] || [subscription.type isEqualToString:@"INAPP_PURCHASE_APPLE"])) {
                        hasAnyTurkcellPackage = YES;
                    }
                }
                if(!hasAnyTurkcellPackage) {
                    if(![AppUtil readDoNotShowAgainFlagForKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"]) {
                        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"TitleLater", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"PortinInfoMessage", @"") withModalType:ModalTypeApprove shouldShowCheck:YES withCheckKey:@"PORTIN_DONTSHOW_DEFAULTS_KEY"];
                        confirm.delegate = self;
                        confirm.tag = 333;
                        [APPDELEGATE showCustomConfirm:confirm];
                    }
                }
            }
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
    
    double percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);
    
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
    [MPush hitEvent:eventValue];
    [MPush hitTag:@"quota_status" withValue:[NSString stringWithFormat:@"%.0f", percentUsageVal]];
    
    if(APPDELEGATE.session.usage.totalStorage - APPDELEGATE.session.usage.usedStorage <= 5242880) {
        [MPush hitTag:@"quota_5_mb_left"];
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
                    [currentWindow addSubview:onkatView];
                }
                
            }
        } else {
            if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
                //TODO no action for now
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
    [currentWindow addSubview:advertisementView];
}

- (void) loadAdvertiesementViewFullMessage: (NSString *) message isFull:(BOOL) isFull withTitle:(NSString *) title {
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    advertisementView = [[CustomAdvertisementView alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height) withMessage:message withFullPackage:YES withTitle:title];
    advertisementView.delegate = self;
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
        [[CurioSDK shared] sendEvent:@"EmailEmpty" eventValue:@"Later"];
        [[CurioSDK shared] sendEvent:@"EmailConfirm" eventValue:@"later"];
        [MPush hitTag:@"EmailEmpty" withValue:@"Later"];
        [MPush hitTag:@"EmailConfirm" withValue:@"later"];
    }
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    if(alertView.tag == 111) {
        [[CurioSDK shared] sendEvent:@"EmailEmpty" eventValue:@"Enter"];
        [[CurioSDK shared] sendEvent:@"EmailConfirm" eventValue:@"ok"];
        [MPush hitTag:@"EmailEmpty" withValue:@"Enter"];
        [MPush hitTag:@"EmailConfirm" withValue:@"ok"];
        EmailEntryController *emailController = [[EmailEntryController alloc] init];
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:emailController];
        [self presentViewController:modalNav animated:YES completion:nil];
    } else if(alertView.tag == 222 || alertView.tag == 333) {
        RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
        storageController.nav = self.nav;
        [self.nav pushViewController:storageController animated:NO];
    }
}

@end

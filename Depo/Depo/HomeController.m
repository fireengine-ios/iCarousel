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
        
        usageChart = [[XYPieChart alloc] initWithFrame:CGRectMake(60, IS_IPHONE_5 ? 40 : 26, 200, 200)];
        usageChart.dataSource = self;
        usageChart.startPieAngle = M_PI_2;
        usageChart.animationSpeed = 1.0;
        usageChart.labelFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:24];
        usageChart.labelRadius = 40;
        usageChart.showLabel = NO;
        usageChart.showPercentage = NO;
        usageChart.pieBackgroundColor = [UIColor whiteColor];
        usageChart.pieCenter = CGPointMake(100, 100);
        usageChart.userInteractionEnabled = NO;
        usageChart.labelShadowColor = [UIColor blackColor];
        [self.view addSubview:usageChart];

        NSString *lastSyncTitle = @"";
        if([SyncUtil readLastSyncDate] != nil) {
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"LastSyncFormat", @""), [AppUtil readDueDateInReadableFormat:[SyncUtil readLastSyncDate]]];
        }
        lastSyncLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, IS_IPHONE_5 ? 18 : 8, self.view.frame.size.width - 40, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:lastSyncTitle withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:lastSyncLabel];
        
        moreStorageButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150)/2, usageChart.frame.origin.y + usageChart.frame.size.height + (IS_IPHONE_5 ? 20 : 0), 150, 44) withTitle:NSLocalizedString(@"GetMoreStorageButtonTitle", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:22];
        moreStorageButton.hidden = YES;
        [moreStorageButton addTarget:self action:@selector(triggerStoragePage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreStorageButton];
        
        footer = [[RecentActivityLinkerFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footer.delegate = self;
        [self.view addSubview:footer];
        
        [usageDao requestUsageInfo];
        [self showLoading];
        
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"onKatViewFlag"]){
            [accountDao requestCurrentAccount];
        }
    }
    return self;
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
    
    usageSummaryView = [[HomeUsageView alloc] initWithFrame:CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130) withUsage:APPDELEGATE.session.usage];
    [usageChart addSubview:usageSummaryView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, moreStorageButton.frame.origin.y + moreStorageButton.frame.size.height + (IS_IPHONE_5 ? 20: 5), self.view.frame.size.width - 40, 1)];
    separator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
    [self.view addSubview:separator];
    
    imageButton = [[UsageButton alloc] initWithFrame:CGRectMake(20, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeImage withStorage:(APPDELEGATE.session.usage.imageUsage + APPDELEGATE.session.usage.videoUsage) withFileCount:(APPDELEGATE.session.usage.imageCount + APPDELEGATE.session.usage.videoCount)];
    [imageButton addTarget:self action:@selector(triggerPhotosPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    musicButton = [[UsageButton alloc] initWithFrame:CGRectMake(122, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeMusic withStorage:APPDELEGATE.session.usage.musicUsage withFileCount:APPDELEGATE.session.usage.audioCount];
    [musicButton addTarget:self action:@selector(triggerMusicPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    otherButton = [[UsageButton alloc] initWithFrame:CGRectMake(225, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeOther withStorage:APPDELEGATE.session.usage.otherUsage withFileCount:APPDELEGATE.session.usage.othersCount];
    [otherButton addTarget:self action:@selector(triggerDocsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
    
    /* contacts commented out
    contactButton = [[UsageButton alloc] initWithFrame:CGRectMake(230, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 75, 60) withUsage:UsageTypeContact withCountValue:@""];
    [contactButton addTarget:self action:@selector(triggerContactsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactButton];
     */

    if(percentUsageVal >= 80) {
        moreStorageButton.hidden = NO;
        usageChart.frame = CGRectMake(60, (moreStorageButton.frame.origin.y + lastSyncLabel.frame.origin.y + lastSyncLabel.frame.size.height)/2 - 100, 200, 200);
        usageSummaryView.frame = CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130);
        [[CurioSDK shared] sendEvent:@"quota_exceeded_80_perc" eventValue:[NSString stringWithFormat:@"current: %.2f", percentUsageVal]];
    } else {
        usageChart.frame = CGRectMake(60, (separator.frame.origin.y + lastSyncLabel.frame.origin.y + lastSyncLabel.frame.size.height)/2 - 100, 200, 200);
        usageSummaryView.frame = CGRectMake((usageChart.frame.size.width - 130)/2, (usageChart.frame.size.height - 130)/2, 130, 130);
    }
    
// contacts commented out //    [contactCountDao requestContactCount];
}

- (void) usageFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) triggerSettingsPage {
    SettingsController *settings = [[SettingsController alloc] init];
    settings.nav = self.nav;
    [self.nav pushViewController:settings animated:NO];
}

- (void) triggerStoragePage {
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:NO];
}

- (void) triggerFilesPage {
    FileListController *file = [[FileListController alloc] initForFolder:nil];
    file.nav = self.nav;
    [self.nav pushViewController:file animated:NO];
}

- (void) triggerPhotosPage {
    PhotoListController *photo = [[PhotoListController alloc] init];
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

- (void) accountSuccessCallback:(Subscription *) subscription{
    currentSubscription = subscription;
    [self flowChartAdvertising];
    /*if ([self shouldShowOnKatView:subscription]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        onkatView = [[OnkatDepoPopUP alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height)];
        onkatView.delegate = self;
        [currentWindow addSubview:onkatView];
    }
     */
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
    if ([AppUtil checkIsUpdate]) {
        if ([AppUtil checkAndSetFlags:DIALOGUE_P7_FLAG]) {
            [self loadAdvertisementView:NSLocalizedString(@"NewVersionNewFeatures", @"") withOption:NO withTitle:NSLocalizedString(@"NewVersionNewFeaturesTitle", @"")];
        }
    }
    else {
        if (APPDELEGATE.session.newUserFlag) {
            if (currentSubscription.plan.cometOfferId.intValue == 581803) {
                if ( [AppUtil checkAndSetFlags:DIALOGUE_P1_FLAG]) {
                    [self loadAdvertisementView:NSLocalizedString(@"WelcomePackage1GB", @"") withOption:NO withTitle:nil];
                }
            }
            else if (currentSubscription.plan.cometOfferId.intValue == 581814){
                if ([AppUtil checkAndSetFlags:DIALOGUE_P2_FLAG]) {
                    [self loadAdvertisementView:NSLocalizedString(@"PlatinPackage500GB", @"") withOption:NO withTitle:NSLocalizedString(@"PlatinPackage500GBTitle", @"")];
                }
            }
            else if (currentSubscription.plan.slcmOfferId.intValue == 603505139){
                if ([AppUtil checkAndSetFlags:DIALOGUE_P3_FLAG]) {
                [self loadAdvertisementView:NSLocalizedString(@"TurkcellPhone5GB", @"") withOption:NO withTitle:nil];
                }
            }
        }
        else {
            if (APPDELEGATE.session.migrationUserFlag && ![currentSubscription.plan.role isEqualToString:@"demo"]) {
                if ([AppUtil checkAndSetFlags:DIALOGUE_P8_FLAG]) {
                    if ([self shouldShowOnKatView:currentSubscription]) {
                        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
                        onkatView = [[OnkatDepoPopUP alloc] initWithFrame:CGRectMake(0, 0, currentWindow.bounds.size.width, currentWindow.bounds.size.height)];
                        onkatView.delegate = self;
                        [currentWindow addSubview:onkatView];
                    }

                }
            }
            else {
                if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
                    
                } else {
                    if (percentUsageVal >= 100 && [AppUtil checkAndSetFlags:DIALOGUE_P6_FLAG] ){
                        [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG];
                        [AppUtil checkAndSetFlags:DIALOGUE_P4_FLAG];
                        [self loadAdvertiesementViewFullMessage:NSLocalizedString(@"StorageFull100", @"") isFull:YES withTitle:NSLocalizedString(@"StorageFull100Title", @"")];
                    }
                    else if (percentUsageVal >= 90 && [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG]){
                        [AppUtil checkAndSetFlags:DIALOGUE_P5_FLAG];
                        [self loadAdvertisementView:NSLocalizedString(@"StorageOver90", @"") withOption:YES withTitle:NSLocalizedString(@"StorageOver90Title", @"")];
                    }
                    else if (percentUsageVal >= 80 && [AppUtil checkAndSetFlags:DIALOGUE_P4_FLAG]){
                        [self loadAdvertisementView:NSLocalizedString(@"StorageOver80", @"") withOption:YES withTitle:NSLocalizedString(@"StorageOver80Title", @"")];
                    }
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
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
    [advertisementView removeFromSuperview];
}

- (void) advertisementViewOkClickWhenFull {
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
    [advertisementView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

@end

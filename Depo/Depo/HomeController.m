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
@synthesize videoButton;

- (id)init {
    self = [super init];
    if (self) {
        UIImageView *imgForTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
        imgForTitle.image = [UIImage imageNamed:@"cloud_icon.png"];
        
        self.navigationItem.titleView = imgForTitle;
        
        usageDao = [[UsageInfoDao alloc] init];
        usageDao.delegate = self;
        usageDao.successMethod = @selector(usageSuccessCallback:);
        usageDao.failMethod = @selector(usageFailCallback:);
        
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
        [moreStorageButton addTarget:self action:@selector(triggerStoragePage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreStorageButton];
        
        footer = [[RecentActivityLinkerFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footer.delegate = self;
        [self.view addSubview:footer];
        
        [usageDao requestUsageInfo];
        [self showLoading];
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
    return [[self.usages objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.usageColors objectAtIndex:(index % self.usageColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will select slice at index %d",index);
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will deselect slice at index %d",index);
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did deselect slice at index %d",index);
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did select slice at index %d",index);
}

- (void) usageSuccessCallback:(Usage *) _usage {
    [self hideLoading];
    APPDELEGATE.session.usage = _usage;
    
    self.usages = [NSMutableArray arrayWithCapacity:5];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.imageUsage]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.musicUsage]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.otherUsage]];
    [usages addObject:[NSNumber numberWithLongLong:APPDELEGATE.session.usage.videoUsage]];
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
    
    imageButton = [[UsageButton alloc] initWithFrame:CGRectMake(20, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 70, 60) withUsage:UsageTypeImage withStorage:APPDELEGATE.session.usage.imageUsage];
    [imageButton addTarget:self action:@selector(triggerPhotosPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    musicButton = [[UsageButton alloc] initWithFrame:CGRectMake(90, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 70, 60) withUsage:UsageTypeMusic withStorage:APPDELEGATE.session.usage.musicUsage];
    [musicButton addTarget:self action:@selector(triggerMusicPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    otherButton = [[UsageButton alloc] initWithFrame:CGRectMake(160, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 70, 60) withUsage:UsageTypeOther withStorage:APPDELEGATE.session.usage.otherUsage];
    [otherButton addTarget:self action:@selector(triggerDocsPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
    
    videoButton = [[UsageButton alloc] initWithFrame:CGRectMake(230, separator.frame.origin.y + (IS_IPHONE_5 ? 41 : 11), 70, 60) withUsage:UsageTypeVideo withStorage:APPDELEGATE.session.usage.videoUsage];
    [videoButton addTarget:self action:@selector(triggerPhotosPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoButton];

}

- (void) usageFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
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

- (void)viewDidLoad {
    [super viewDidLoad];
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

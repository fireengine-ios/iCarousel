//
//  TodayViewController.m
//  AutoSyncWidget
//
//  Created by Mahir on 02/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

//TODO group id for shared nsuserdefaults - this will be revisited for Turkcell
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.igones"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

@synthesize topLabel;
@synthesize bottomLabel;
@synthesize progress;

- (id)initWithCoder:(NSCoder *) decoder {
    if (self = [super initWithCoder:decoder]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(320, 65);
    topLabel.text = NSLocalizedString(@"WidgetTopTitleFinished", @"");
    bottomLabel.text = @"-- / --";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:nil];

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncQueueChanged:) name:@"AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION" object:nil];
}

- (void) userDefaultsDidChange {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
    NSInteger totalCount = [defaults integerForKey:@"totalAutoSyncCount"];
    NSInteger finishedCount = [defaults integerForKey:@"finishedAutoSyncCount"];

    if(finishedCount == totalCount) {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleFinished", @"");
        bottomLabel.text = @"-- / --";
    } else {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleInProgress", @"");
        bottomLabel.text = [NSString stringWithFormat:@"%d / %d", (int)finishedCount + 1, (int)totalCount];
        [progress startAnimating];
    }
}

- (void) syncQueueChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo == nil) {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleFinished", @"");
        bottomLabel.text = @"-- / --";
        [progress stopAnimating];
    } else {
        NSNumber *totalCount = [userInfo objectForKey:@"totalAutoSyncCount"];
        NSNumber *finishedCount = [userInfo objectForKey:@"finishedAutoSyncCount"];

        topLabel.text = NSLocalizedString(@"WidgetTopTitleInProgress", @"");
        [progress startAnimating];
        if(totalCount != nil && finishedCount != nil) {
            bottomLabel.text = [NSString stringWithFormat:@"%d / %d", finishedCount.intValue + 1, totalCount.intValue];
        } else {
            bottomLabel.text = @"-- / --";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSLog(@"At widgetPerformUpdateWithCompletionHandler");
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
    NSInteger totalCount = [defaults integerForKey:@"totalAutoSyncCount"];
    NSInteger finishedCount = [defaults integerForKey:@"finishedAutoSyncCount"];
    
    if(finishedCount == totalCount) {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleFinished", @"");
        bottomLabel.text = @"-- / --";
    } else {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleInProgress", @"");
        bottomLabel.text = [NSString stringWithFormat:@"%d / %d", (int)finishedCount + 1, (int)totalCount];
        [progress startAnimating];
    }

    completionHandler(NCUpdateResultNewData);
}

@end

//
//  TodayViewController.m
//  AutoSyncWidget
//
//  Created by Mahir on 02/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#ifdef PLATFORM_STORE
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillidepo"
#elif defined PLATFORM_ICT
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillideponew.ent"
#else
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.igones.Depo"
#endif

#define EXTENSION_WORMHOLE_DIR @"WORMHOLE_DIR"

#define EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER"

#define EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

@synthesize topLabel;
@synthesize bottomLabel;
@synthesize progress;
@synthesize tickView;
@synthesize wormhole;
@synthesize finishedCount;
@synthesize totalCount;

- (id)initWithCoder:(NSCoder *) decoder {
    if (self = [super initWithCoder:decoder]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
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
    
    wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:GROUP_NAME_SUITE_NSUSERDEFAULTS optionalDirectory:EXTENSION_WORMHOLE_DIR];
    [wormhole listenForMessageWithIdentifier:EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER listener:^(id messageObject) {
        NSNumber *number = [messageObject valueForKey:@"totalCount"];
        self.totalCount = [number intValue];
        [self updateFields];
    }];
    [wormhole listenForMessageWithIdentifier:EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER listener:^(id messageObject) {
        NSNumber *number = [messageObject valueForKey:@"finishedCount"];
        self.finishedCount = [number intValue];
        [self updateFields];
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:nil];

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncQueueChanged:) name:@"AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION" object:nil];
}

- (void) updateFields {
    if(finishedCount == totalCount) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
        NSString *lastSyncDateInReadableFormat = [defaults valueForKey:@"lastSyncDate"];
        
        topLabel.text = NSLocalizedString(@"WidgetTopTitleFinished", @"");
        bottomLabel.text = lastSyncDateInReadableFormat;
        progress.hidden = YES;
        tickView.hidden = NO;
    } else {
        topLabel.text = NSLocalizedString(@"WidgetTopTitleInProgress", @"");
        bottomLabel.text = [NSString stringWithFormat:@"%d / %d", (int)finishedCount + 1, (int)totalCount];
        progress.hidden = NO;
        tickView.hidden = YES;
        [progress startAnimating];
    }
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSLog(@"AT userDefaultsDidChange:");

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
    self.totalCount = (int)[defaults integerForKey:@"totalAutoSyncCount"];
    self.finishedCount = (int)[defaults integerForKey:@"finishedAutoSyncCount"];

    [self updateFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSLog(@"At widgetPerformUpdateWithCompletionHandler");
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
    self.totalCount = (int)[defaults integerForKey:@"totalAutoSyncCount"];
    self.finishedCount = (int)[defaults integerForKey:@"finishedAutoSyncCount"];
    
    [self updateFields];
    
    completionHandler(NCUpdateResultNewData);
}

@end

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

@interface HomeController ()

@end

@implementation HomeController

@synthesize footer;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"HomeTitle", @"");
        
        footer = [[RecentActivityLinkerFooter alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footer.delegate = self;
        [self.view addSubview:footer];
    }
    return self;
}

#pragma mark RecentActivityLinker Method

- (void) recentActivityLinkerDidTriggerPage {
    [APPDELEGATE.base showRecentActivities];
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

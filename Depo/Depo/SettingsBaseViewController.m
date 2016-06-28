//
//  SettingsBaseViewController.m
//  Depo
//
//  Created by Salih Topcu on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"

@interface SettingsBaseViewController ()

@end

@implementation SettingsBaseViewController

@synthesize pageContentTable;

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self drawPageContentTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)drawPageContentTable {
    if (pageContentTable != nil)
        [pageContentTable removeFromSuperview];
    pageContentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex) style:UITableViewStylePlain];
    pageContentTable.delegate = self;
    pageContentTable.dataSource = self;
    pageContentTable.backgroundColor = [UIColor clearColor];
    pageContentTable.backgroundView = nil;
    pageContentTable.bounces = NO;
    [pageContentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:pageContentTable];
}

- (void) setAuto {
    currentSetting = EnableOptionAuto;
    [self drawPageContentTable];
}

- (void) setOn {
    currentSetting = EnableOptionOn;
    [self drawPageContentTable];
}

- (void) setOff {
    currentSetting = EnableOptionOff;
    [self drawPageContentTable];
}

- (NSString *) getEnableOptionName:(int)value {
    switch (value) {
        case EnableOptionAuto: return NSLocalizedString(@"Auto", @"");
        case EnableOptionOn: return NSLocalizedString(@"On", @"");
        case EnableOptionOff: return NSLocalizedString(@"Off", @"");
        default : return @"";
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

//
//  SocialBaseController.m
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SocialBaseController.h"
#import "Util.h"

@interface SocialBaseController ()

@end

@implementation SocialBaseController

@synthesize mainStatusView;
@synthesize percentLabel;
@synthesize resultTable;
@synthesize exportButton;
@synthesize recentStatus;

- (id) initWithImageName:(NSString *) imgName withMessage:(NSString *) message {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"FacebookExportTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"f5f5f5"];
        
        float buttonSize = 280;
        
        UIImage *iconImg = [UIImage imageNamed:imgName];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - iconImg.size.width)/2, 30, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self.view addSubview:iconView];
        
        CustomLabel *infoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(30, iconView.frame.origin.y + iconView.frame.size.height + 20, self.view.frame.size.width - 60, 60) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:message withAlignment:NSTextAlignmentCenter numberOfLines:3];
        [self.view addSubview:infoTitle];
        
        exportButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize)/2, infoTitle.frame.origin.y + infoTitle.frame.size.height + 20, buttonSize, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"StartExport", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [exportButton addTarget:self action:@selector(triggerExport) forControlEvents:UIControlEventTouchUpInside];
        exportButton.enabled = NO;
        exportButton.isAccessibilityElement = YES;
        exportButton.accessibilityIdentifier = @"exportButtonSocialBase";
        [self.view addSubview:exportButton];
        
        resultTable = [[UITableView alloc] initWithFrame:CGRectMake(20, exportButton.frame.origin.y + exportButton.frame.size.height + 10, self.view.frame.size.width - 40, 90) style:UITableViewStylePlain];
        resultTable.backgroundColor = [UIColor clearColor];
        resultTable.backgroundView = nil;
        resultTable.delegate = self;
        resultTable.dataSource = self;
        resultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        resultTable.bounces = NO;
        resultTable.isAccessibilityElement = YES;
        resultTable.accessibilityIdentifier = @"resultTableSocialBase";
        [self.view addSubview:resultTable];
        
        mainStatusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        mainStatusView.hidden = YES;
        mainStatusView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:mainStatusView];
        
        UIImageView *statusBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainStatusView.frame.size.width, mainStatusView.frame.size.height)];
        statusBgImgView.image = [UIImage imageNamed:@"bg_fullimg.png"];
        [mainStatusView addSubview:statusBgImgView];
        
        UIImage *statusBgImg = [UIImage imageNamed:@"bg_cloud_big.png"];
        float statusInfoWidth = mainStatusView.frame.size.width - 80;
        float statusInfoHeight = statusInfoWidth * statusBgImg.size.height/statusBgImg.size.width;
        UIImageView *statusInfoView = [[UIImageView alloc] initWithFrame:CGRectMake((mainStatusView.frame.size.width - statusInfoWidth)/2, (mainStatusView.frame.size.height - statusInfoHeight)/2 - 50, statusInfoWidth, statusInfoHeight)];
        statusInfoView.image = statusBgImg;
        [mainStatusView addSubview:statusInfoView];
        
        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((statusInfoView.frame.size.width - 100)/2, (statusInfoView.frame.size.height - 40)/2, 100, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:34] withColor:[Util UIColorForHexColor:@"555555"] withText:@""];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [statusInfoView addSubview:percentLabel];
        
        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, percentLabel.frame.origin.y + percentLabel.frame.size.height + 5, statusInfoView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ExportingFiles", @"") withAlignment:NSTextAlignmentCenter];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [statusInfoView addSubview:subInfoLabel];
        
    }
    return self;
}

- (void) triggerExport {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
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

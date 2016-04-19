//
//  DropboxExportController.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxExportController.h"
#import "CustomButton.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxExportResult.h"
#import "Util.h"

@interface DropboxExportController ()

@end

@implementation DropboxExportController

@synthesize circleView;
@synthesize percentLabel;
@synthesize statusChart;
@synthesize statusList;
@synthesize statusColors;
@synthesize connectDao;
@synthesize startDao;
@synthesize statusDao;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"ExportFromDropbox", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"f5f5f5"];

        float buttonSize = 280;
        
        CustomButton *exportButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonSize)/2, 50, buttonSize, 60) withImageName:@"buttonbg_yellow.png" withTitle:NSLocalizedString(@"Export", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor]];
        [exportButton addTarget:self action:@selector(triggerExport) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:exportButton];

        statusChart = [[XYPieChart alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120)/2, exportButton.frame.origin.y + exportButton.frame.size.height + 5, 120, 120)];
        statusChart.dataSource = self;
        statusChart.startPieAngle = -M_PI_2;
        statusChart.animationSpeed = 0.01;
        statusChart.showLabel = NO;
        statusChart.showPercentage = NO;
        statusChart.pieBackgroundColor = [UIColor whiteColor];
        //        statusChart.pieCenter = CGPointMake(200, 200);
        statusChart.userInteractionEnabled = NO;
        statusChart.labelShadowColor = [UIColor blackColor];
        [self.view addSubview:statusChart];
        
        UIImage *circleImg = [UIImage imageNamed:@"yuvarlakbulut.png"];
        circleView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 90)/2, exportButton.frame.origin.y + exportButton.frame.size.height + 20, 90, 90)];
        circleView.image = circleImg;
        [self.view addSubview:circleView];
        
        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, exportButton.frame.origin.y + exportButton.frame.size.height + 50, 70, 30) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:25] withColor:[Util UIColorForHexColor:@"555555"] withText:@""];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:percentLabel];
        
        [self performSelector:@selector(tempShowStatus) withObject:nil afterDelay:2.0f];
    }
    return self;
}

- (void) tempShowStatus {
    DropboxExportResult *temp = [[DropboxExportResult alloc] init];
    temp.progress = 40;
    [self statusSuccessCallback:temp];
}

- (void) triggerExport {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) statusSuccessCallback:(DropboxExportResult *) status {
    [self hideLoading];
    percentLabel.text = [NSString stringWithFormat:@"%%%d", (int)status.progress];
    self.statusList = [NSMutableArray arrayWithCapacity:2];
    [statusList addObject:[NSNumber numberWithFloat:status.progress]];
    [statusList addObject:[NSNumber numberWithFloat:(100 - status.progress)]];
    
    self.statusColors =[NSArray arrayWithObjects:
                        [Util UIColorForHexColor:@"3fb0e8"],
                        [Util UIColorForHexColor:@"FFFFFF"], nil];
    
    [statusChart reloadData];
}

- (void) statusFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return [self.statusList count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.statusList objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.statusColors objectAtIndex:(index % self.statusColors.count)];
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

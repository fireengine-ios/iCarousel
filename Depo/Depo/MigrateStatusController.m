//
//  MigrateStatusController.m
//  Depo
//
//  Created by Mahir on 01/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MigrateStatusController.h"
#import "Util.h"
#import "MigrationStatus.h"
#import "AppDelegate.h"

@interface MigrateStatusController ()

@end

@implementation MigrateStatusController

@synthesize statusDao;
@synthesize migrateDao;
@synthesize circleView;
@synthesize percentLabel;
@synthesize statusChart;
@synthesize statusList;
@synthesize statusColors;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        statusDao = [[MigrateStatusDao alloc] init];
        statusDao.delegate = self;
        statusDao.successMethod = @selector(statusSuccessCallback:);
        statusDao.failMethod = @selector(statusFailCallback:);
        
        migrateDao = [[MigrateDao alloc] init];
        migrateDao.delegate = self;
        migrateDao.successMethod = @selector(migrateSuccessCallback);
        migrateDao.failMethod = @selector(migrateFailCallback:);
        
        UIImage *topImg = [UIImage imageNamed:@"bulutheader.png"];
        UIImageView *topImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, topImg.size.width, topImg.size.height)];
        topImgView.image = topImg;
        [self.view addSubview:topImgView];
        
        UIImage *infoBgImg = [UIImage imageNamed:@"karebg.png"];
        UIImageView *infoBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - infoBgImg.size.width)/2, topImgView.frame.origin.y + topImgView.frame.size.height + 50, infoBgImg.size.width, infoBgImg.size.height)];
        infoBgImgView.image = infoBgImg;
        [self.view addSubview:infoBgImgView];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(infoBgImgView.frame.origin.x, infoBgImgView.frame.origin.y + 20, infoBgImgView.frame.size.width, 30) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:24] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"MigrationTitle", @"") withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:titleLabel];

        statusChart = [[XYPieChart alloc] initWithFrame:CGRectMake(infoBgImgView.frame.origin.x + 5, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, 120, 120)];
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
        circleView = [[UIImageView alloc] initWithFrame:CGRectMake(infoBgImgView.frame.origin.x + 20, titleLabel.frame.origin.y + titleLabel.frame.size.height + 20, 90, 90)];
        circleView.image = circleImg;
        [self.view addSubview:circleView];
        
        percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(150, titleLabel.frame.origin.y + titleLabel.frame.size.height + 30, 140, 70) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:60] withColor:[Util UIColorForHexColor:@"555555"] withText:@""];
        [self.view addSubview:percentLabel];
        
        CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(infoBgImgView.frame.origin.x + 10, infoBgImgView.frame.origin.y + infoBgImgView.frame.size.height - 80, infoBgImgView.frame.size.width - 20, 60) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:17] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"MigrationSubTitle", @"") withAlignment:NSTextAlignmentLeft];
        subTitleLabel.numberOfLines = 3;
        [self.view addSubview:subTitleLabel];
        
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [migrateDao requestSendMigrate];
    [self showLoading];
}

- (void) tempFillChart {
    MigrationStatus *status = [[MigrationStatus alloc] init];
    status.progress = 40;
    status.status = @"PROGRESS";
    [self statusSuccessCallback:status];
}

- (void) drawArc {
    CGFloat radius = circleView.frame.size.width/2 + 3;
    CGFloat inset  = 1;

    // Create a white pie-chart-like shape inside the white ring (above).
    // The outside of the shape should be inside the ring, therefore the
    // frame needs to be inset radius/2 (for its outside to be on
    // the outside of the ring) + 2 (to be 2 points in).
    CAShapeLayer *pieShape = [CAShapeLayer layer];
    inset = radius/2 + 2; // The inset is updated here
    pieShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(circleView.frame.origin.x - 3, circleView.frame.origin.y - 3, circleView.frame.size.width/2 + 3, circleView.frame.size.height/2 + 3) cornerRadius:radius-inset].CGPath;
    
    pieShape.fillColor   = [UIColor whiteColor].CGColor;
    pieShape.strokeColor = [UIColor whiteColor].CGColor;
    pieShape.lineWidth   = (radius-inset)*2;
    
    // Add sublayers
    // NOTE: the following code is used in a UIView subclass (thus self is a view)
    // If you instead chose to use this code in a view controller you should instead
    // use self.view.layer to access the view of your view controller.
    [self.view.layer addSublayer:pieShape];
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

- (void) statusSuccessCallback:(MigrationStatus *) status {
    [self hideLoading];
    if([status.status isEqualToString:@"FINISHED"]) {
        [APPDELEGATE triggerPostTermsAndMigration];
        [self.view removeFromSuperview];
    } else {
        percentLabel.text = [NSString stringWithFormat:@"%%%d", (int)status.progress];
        self.statusList = [NSMutableArray arrayWithCapacity:2];
        [statusList addObject:[NSNumber numberWithFloat:status.progress]];
        [statusList addObject:[NSNumber numberWithFloat:(100 - status.progress)]];
        
        self.statusColors =[NSArray arrayWithObjects:
                            [Util UIColorForHexColor:@"3fb0e8"],
                            [Util UIColorForHexColor:@"FFFFFF"], nil];
        
        [statusChart reloadData];
        
        [statusDao performSelector:@selector(requestMigrationStatus) withObject:nil afterDelay:2.0f];
    }
}

- (void) statusFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void) migrateSuccessCallback {
    [statusDao requestMigrationStatus];
}

- (void) migrateFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"MigrateStatusController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

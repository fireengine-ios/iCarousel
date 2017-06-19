//
//  CellographMainController.m
//  Depo
//
//  Created by Mahir Tarlan on 18/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CellographMainController.h"

@interface CellographMainController ()

@end

@implementation CellographMainController

@synthesize segmentView;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        segmentView = [[CellographSegmentView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, 60)];
        segmentView.delegate = self;
        [self.view addSubview:segmentView];
    }
    return self;
}

- (void) cellographHeaderDidSelectCurrent {
}

- (void) cellographHeaderDidSelectHistory {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  LocalImageDetailModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 22/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "LocalImageDetailModalController.h"
#import "Util.h"
#import "AppConstants.h"
#import "GeneralTextField.h"

@interface LocalImageDetailModalController ()

@end

@implementation LocalImageDetailModalController

@synthesize asset;

- (id) initWithAsset:(ALAsset *) _asset {
    if(self = [super init]) {
        self.asset = _asset;
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"FileDetailTitle", @"");
        
        CustomButton *doneButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"DoneButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [doneButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        self.navigationItem.rightBarButtonItem = doneItem;

        float yIndex = self.topIndex + (IS_IPAD ? 100 : 40);
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailNameTitle", @"")];
        [self.view addSubview:titleLabel];
        
        yIndex += 20;
        
        GeneralTextField *nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, 43) withPlaceholder:NSLocalizedString(@"FileNamePlaceholder", @"")];
        nameField.text = [self.asset.defaultRepresentation filename];
        nameField.enabled = NO;
        nameField.isAccessibilityElement = YES;
        nameField.accessibilityIdentifier = @"nameFieldFileDetail";
        [self.view addSubview:nameField];
        
        yIndex += 80;

        CustomLabel *sizeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, yIndex, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailSize", @"")];
        [self.view addSubview:sizeLabel];
        
        CustomLabel *sizeValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 125, yIndex, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[Util transformedSizeValue:[self.asset.defaultRepresentation size]]];
        sizeValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:sizeValueLabel];
        
        yIndex += 40;
    }
    return self;
}

- (void) triggerDone {
    [self dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

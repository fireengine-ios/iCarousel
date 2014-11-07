//
//  FolderDetailModalController.m
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FolderDetailModalController.h"
#import "Util.h"

@interface FolderDetailModalController ()

@end

@implementation FolderDetailModalController

@synthesize delegate;
@synthesize folder;
@synthesize nameField;

- (id) initWithFolder:(MetaFile *) _folder {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.folder = _folder;
        self.title = NSLocalizedString(@"FolderDetailTitle", @"");

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        CustomButton *doneButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"DoneButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [doneButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, self.topIndex + 30, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderAddTitle", @"")];
        [self.view addSubview:titleLabel];
        
        nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, self.topIndex + 55, 280, 43) withPlaceholder:NSLocalizedString(@"FolderNamePlaceholder", @"")];
        nameField.delegate = self;
        if(self.folder != nil) {
            nameField.text = self.folder.name;
        }
        [self.view addSubview:nameField];
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, nameField.frame.origin.y + nameField.frame.size.height + 30, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailSegmentTitle", @"")];
        [self.view addSubview:detailLabel];

        UIView *detailSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, detailLabel.frame.origin.y + detailLabel.frame.size.height + 10, self.view.frame.size.width, 1)];
        detailSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:detailSeparator];

        //item segment
        CustomLabel *itemsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailItems", @"")];
        [self.view addSubview:itemsLabel];
        
        CustomLabel *itemsValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(200, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[NSString stringWithFormat:@"%d", self.folder.itemCount]];
        itemsValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:itemsValueLabel];

        UIView *itemsSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, itemsLabel.frame.origin.y + itemsLabel.frame.size.height + 15, self.view.frame.size.width, 1)];
        itemsSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:itemsSeparator];

        //size segment
        CustomLabel *sizeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, itemsSeparator.frame.origin.y + itemsSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailSize", @"")];
        [self.view addSubview:sizeLabel];
        
        CustomLabel *sizeValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(200, itemsSeparator.frame.origin.y + itemsSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[Util transformedSizeValue:self.folder.bytes]];
        sizeValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:sizeValueLabel];

        UIView *sizeSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, sizeLabel.frame.origin.y + sizeLabel.frame.size.height + 15, self.view.frame.size.width, 1)];
        sizeSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:sizeSeparator];

        //modify date segment
        CustomLabel *dateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, sizeSeparator.frame.origin.y + sizeSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailModifyDate", @"")];
        [self.view addSubview:dateLabel];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMM yyyy"];
        
        CustomLabel *dateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(200, sizeSeparator.frame.origin.y + sizeSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.folder.lastModified]];
        dateValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:dateValueLabel];

        UIView *dateSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, dateLabel.frame.origin.y + dateLabel.frame.size.height + 15, self.view.frame.size.width, 1)];
        dateSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:dateSeparator];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void) triggerDone {
    NSString *finalName = nameField.text;
    if(![finalName isEqualToString:self.folder.name]) {
        [delegate folderDetailShouldRename:finalName];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:nameField]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [nameField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [nameField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [nameField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

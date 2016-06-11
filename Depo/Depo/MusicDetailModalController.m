//
//  MusicDetailModalController.m
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicDetailModalController.h"
#import "Util.h"

@interface MusicDetailModalController ()

@end

@implementation MusicDetailModalController

@synthesize delegate;
@synthesize file;
@synthesize nameField;

- (id) initWithFile:(MetaFile *) _file {
    if(self = [super init]) {
        self.file = _file;
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"MUZIKA";//NSLocalizedString(@"FileDetailTitle", @"");
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        CustomButton *doneButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"DoneButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [doneButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, self.topIndex + 30, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailNameTitle", @"")];
        [self.view addSubview:titleLabel];
        
        nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, self.topIndex + 55, 280, 43) withPlaceholder:NSLocalizedString(@"FileNamePlaceholder", @"")];
        nameField.delegate = self;
        nameField.text = self.file.name;
        [self.view addSubview:nameField];
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, nameField.frame.origin.y + nameField.frame.size.height + 30, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FileDetailSegmentTitle", @"")];
        [self.view addSubview:detailLabel];
        
        UIView *detailSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, detailLabel.frame.origin.y + detailLabel.frame.size.height + 10, self.view.frame.size.width, 1)];
        detailSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:detailSeparator];
        
        //size segment
        CustomLabel *sizeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderDetailSize", @"")];
        [self.view addSubview:sizeLabel];
        
        CustomLabel *sizeValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(200, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[Util transformedSizeValue:self.file.bytes]];
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
        
        CustomLabel *dateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(200, sizeSeparator.frame.origin.y + sizeSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.file.lastModified]];
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
    if(![finalName isEqualToString:self.file.name]) {
        [delegate musicDetailShouldRename:finalName];
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
    IGLog(@"MusicDetailModalController viewDidLoad");
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

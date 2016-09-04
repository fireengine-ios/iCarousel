//
//  AlbumDetailModalController.m
//  Depo
//
//  Created by Mahir on 14.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumDetailModalController.h"
#import "Util.h"

@interface AlbumDetailModalController ()

@end

@implementation AlbumDetailModalController

@synthesize delegate;
@synthesize album;
@synthesize nameField;

- (id) initWithAlbum:(PhotoAlbum *) _album {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.album = _album;
        self.title = NSLocalizedString(@"AlbumDetailTitle", @"");
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        CustomButton *doneButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"DoneButtonTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [doneButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        float rowWidth = 280;
        float calculatedTopIndex = self.topIndex + 30;
        if(IS_IPAD) {
            rowWidth = 500;
            calculatedTopIndex = self.topIndex + 100;
        }
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, calculatedTopIndex, rowWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumAddTitle", @"")];
        [self.view addSubview:titleLabel];
        
        nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, rowWidth, 43) withPlaceholder:NSLocalizedString(@"AlbumNamePlaceholder", @"")];
        nameField.delegate = self;
        nameField.text = self.album.label;
        if(self.album.isReadOnly) {
            nameField.enabled = NO;
        }
        [self.view addSubview:nameField];
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, nameField.frame.origin.y + nameField.frame.size.height + (IS_IPAD ? 60 : 30), rowWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumDetailSegmentTitle", @"")];
        [self.view addSubview:detailLabel];
        
        UIView *detailSeparator = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, detailLabel.frame.origin.y + detailLabel.frame.size.height + 10, rowWidth, 1)];
        detailSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:detailSeparator];
        
        //item segment
        CustomLabel *itemsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumDetailItems", @"")];
        [self.view addSubview:itemsLabel];
        
        CustomLabel *itemsValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width + rowWidth)/2 - 95, detailSeparator.frame.origin.y + detailSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[NSString stringWithFormat:@"%d", self.album.imageCount + self.album.videoCount]];
        itemsValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:itemsValueLabel];
        
        UIView *itemsSeparator = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, itemsLabel.frame.origin.y + itemsLabel.frame.size.height + 15, rowWidth, 1)];
        itemsSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:itemsSeparator];
        
        //size segment
        CustomLabel *sizeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, itemsSeparator.frame.origin.y + itemsSeparator.frame.size.height + 15, 175, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumDetailSize", @"")];
        [self.view addSubview:sizeLabel];
        
        CustomLabel *sizeValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width + rowWidth)/2 - 95, itemsSeparator.frame.origin.y + itemsSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[Util transformedSizeValue:self.album.bytes]];
        sizeValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:sizeValueLabel];
        
        UIView *sizeSeparator = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, sizeLabel.frame.origin.y + sizeLabel.frame.size.height + 15, rowWidth, 1)];
        sizeSeparator.backgroundColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self.view addSubview:sizeSeparator];
        
        //modify date segment
        CustomLabel *dateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, sizeSeparator.frame.origin.y + sizeSeparator.frame.size.height + 15, rowWidth, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumDetailModifyDate", @"")];
        [self.view addSubview:dateLabel];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMM yyyy"];
        
        CustomLabel *dateValueLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width + rowWidth)/2 - 95, sizeSeparator.frame.origin.y + sizeSeparator.frame.size.height + 15, 95, 25) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:20] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[dateFormat stringFromDate:self.album.lastModifiedDate]];
        dateValueLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:dateValueLabel];
        
        UIView *dateSeparator = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - rowWidth)/2, dateLabel.frame.origin.y + dateLabel.frame.size.height + 15, rowWidth, 1)];
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
    if(![finalName isEqualToString:self.album.label]) {
        [delegate albumDetailShouldRenameWithName:finalName];
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
    IGLog(@"AlbumDetailModalController viewDidLoad");
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

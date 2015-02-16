//
//  NewFolderModalController.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "NewFolderModalController.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "Util.h"

@interface NewFolderModalController ()

@end

@implementation NewFolderModalController

@synthesize delegate;
@synthesize nameField;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"NewFolderTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;

        CustomButton *addButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCreate", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [addButton addTarget:self action:@selector(triggerAdd) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = addItem;
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(25, self.topIndex + 30, 280, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FolderAddTitle", @"")];
        [self.view addSubview:titleLabel];
        
        nameField = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, self.topIndex + 55, 280, 43) withPlaceholder:NSLocalizedString(@"FolderNamePlaceholder", @"")];
        nameField.delegate = self;
        [self.view addSubview:nameField];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];

    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) triggerAdd {
    if([nameField.text length] > 0) {
        [nameField resignFirstResponder];
        [delegate newFolderModalDidTriggerNewFolderWithName:nameField.text];
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FolderAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FolderAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FolderAddFailMessage", @"")];
    }
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
    [textField setSelectedTextRange:[textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument]];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [nameField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [nameField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

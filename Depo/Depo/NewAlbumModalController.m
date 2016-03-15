//
//  NewAlbumModalController.m
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "NewAlbumModalController.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppConstants.h"

@interface NewAlbumModalController ()

@end

@implementation NewAlbumModalController

@synthesize delegate;
@synthesize nameField;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"NewAlbumTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        CustomButton *addButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCreate", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [addButton addTarget:self action:@selector(triggerAdd) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = addItem;
        
        CGRect titleRect = CGRectMake(25, self.topIndex + 30, 280, 20);
        CGRect nameRect = CGRectMake(20, self.topIndex + 55, 280, 43);
        if(IS_IPAD) {
            titleRect = CGRectMake((self.view.frame.size.width - 400)/2, self.topIndex + 80, 400, 20);
            nameRect = CGRectMake((self.view.frame.size.width - 400)/2, self.topIndex + 130, 400, 43);
        }
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:titleRect withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"AlbumAddTitle", @"")];
        [self.view addSubview:titleLabel];
        
        nameField = [[GeneralTextField alloc] initWithFrame:nameRect withPlaceholder:NSLocalizedString(@"AlbumNamePlaceholder", @"")];
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
        [delegate newAlbumModalDidTriggerNewAlbumWithName:nameField.text];
        [self dismissViewControllerAnimated:YES completion:nil];
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

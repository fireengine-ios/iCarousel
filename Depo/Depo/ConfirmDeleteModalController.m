//
//  ConfirmDeleteModalController.m
//  Depo
//
//  Created by Mahir on 10/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ConfirmDeleteModalController.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "Util.h"
#import "CacheUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface ConfirmDeleteModalController ()

@end

@implementation ConfirmDeleteModalController

@synthesize delegate;
@synthesize cancelButton;
@synthesize confirmButton;
@synthesize checkButton;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ConfirmDeleteTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        UIFont *messageFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:15];
        UIFont *confirmFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:16];
        UIFont *checkFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:17];
        
        int yIndex = 30;
        
        UIImage *deleteImg = [UIImage imageNamed:@"big_delete_icon.png"];
        UIImageView *deleteImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - deleteImg.size.width)/2, yIndex, deleteImg.size.width, deleteImg.size.height)];
        deleteImgView.image = deleteImg;
        [self.view addSubview:deleteImgView];
        
        yIndex += deleteImg.size.height + 20;
        
        int messageHeight = [Util calculateHeightForText:NSLocalizedString(@"ConfirmDeleteMessage", @"") forWidth:self.view.frame.size.width-40 forFont:messageFont] + 10;
        
        CustomLabel *messageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, messageHeight) withFont:messageFont withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ConfirmDeleteMessage", @"")];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [self.view addSubview:messageLabel];

        yIndex += messageHeight + 10;

        CustomLabel *confirmLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, 24) withFont:confirmFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ConfirmDeleteQuestion", @"")];
        confirmLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:confirmLabel];

        yIndex += 40;

        cancelButton = [[SimpleButton alloc] initWithFrame:CGRectMake(30, yIndex, 120, 50) withTitle:NSLocalizedString(@"TitleNo", @"") withBorderColor:[Util UIColorForHexColor:@"e9ebef"] withBgColor:[Util UIColorForHexColor:@"FFFFFF"]];
        [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];

        confirmButton = [[SimpleButton alloc] initWithFrame:CGRectMake(170, yIndex, 120, 50) withTitle:NSLocalizedString(@"TitleYes", @"") withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"]];
        [confirmButton addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:confirmButton];

        yIndex += 68;

        checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(50, yIndex, 21, 20) isInitiallyChecked:YES];
        [self.view addSubview:checkButton];

        CustomLabel *checkLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(80, yIndex, self.view.frame.size.width - 100, 20) withFont:checkFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"MessageDontShowAgainCheck", @"")];
        [self.view addSubview:checkLabel];
    }
    return self;
}

- (void) cancelClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) confirmClicked {
    if(checkButton.isChecked) {
        [CacheUtil setConfirmDeletePageFlag];
    }
    [delegate confirmDeleteDidConfirm];
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

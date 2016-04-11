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
        
        int yIndex = IS_IPAD ? 120 : 30;
        
        UIImage *deleteImg = [UIImage imageNamed:@"big_delete_icon.png"];
        UIImageView *deleteImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - deleteImg.size.width)/2, yIndex, deleteImg.size.width, deleteImg.size.height)];
        deleteImgView.image = deleteImg;
        [self.view addSubview:deleteImgView];
        
        yIndex += deleteImg.size.height + (IS_IPAD ? 40 : 20);
        
        float messageWidth = IS_IPAD ? 400 : 280;
        
        int messageHeight = [Util calculateHeightForText:NSLocalizedString(@"ConfirmDeleteMessage", @"") forWidth:messageWidth forFont:messageFont] + 10;
        
        CustomLabel *messageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth, messageHeight) withFont:messageFont withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ConfirmDeleteMessage", @"")];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [self.view addSubview:messageLabel];

        yIndex += messageHeight + (IS_IPAD ? 30 : 10);

        CustomLabel *confirmLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth, 24) withFont:confirmFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ConfirmDeleteQuestion", @"")];
        confirmLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:confirmLabel];

        yIndex += 40 + (IS_IPAD ? 20 : 0);

        cancelButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth/2 - 10, 50) withTitle:NSLocalizedString(@"TitleNo", @"") withBorderColor:[Util UIColorForHexColor:@"e9ebef"] withBgColor:[Util UIColorForHexColor:@"FFFFFF"]];
        [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];

        confirmButton = [[SimpleButton alloc] initWithFrame:CGRectMake(cancelButton.frame.origin.x + cancelButton.frame.size.width + 20, yIndex, messageWidth/2 - 10, 50) withTitle:NSLocalizedString(@"TitleYes", @"") withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"]];
        [confirmButton addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:confirmButton];

        yIndex += 68 + (IS_IPAD ? 20 : 0);

        checkButton = [[CheckButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2 + 20, yIndex, 21, 20) isInitiallyChecked:NO];
//        [checkButton addTarget:self action:@selector(toggleCheck) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:checkButton];

        CustomLabel *checkLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(checkButton.frame.origin.x + checkButton.frame.size.width + 10, yIndex, messageWidth - 50, 20) withFont:checkFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"MessageDontShowAgainCheck", @"")];
        [self.view addSubview:checkLabel];
    }
    return self;
}

- (void) toggleCheck {
    [checkButton toggle];
}

- (void) cancelClicked {
    [delegate confirmDeleteDidCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) confirmClicked {
    if(checkButton.isChecked) {
        [CacheUtil setConfirmDeletePageFlag];
    }
    [delegate confirmDeleteDidConfirm];
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

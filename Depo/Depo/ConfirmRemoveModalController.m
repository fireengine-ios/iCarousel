//
//  ConfirmRemoveModalController.m
//  Depo
//
//  Created by Seyma Tanoglu on 09/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ConfirmRemoveModalController.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "Util.h"
#import "CacheUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface ConfirmRemoveModalController ()

@end

@implementation ConfirmRemoveModalController

@synthesize delegate;
@synthesize cancelButton;
@synthesize confirmButton;
@synthesize checkButton;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ConfirmRemoveTitle", @"");
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
        
        int messageHeight = [Util calculateHeightForText:NSLocalizedString(@"ConfirmRemoveMessage", @"") forWidth:messageWidth forFont:messageFont] + 10;
        
        CustomLabel *messageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth, messageHeight) withFont:messageFont withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ConfirmRemoveMessage", @"")];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [self.view addSubview:messageLabel];
        
        yIndex += messageHeight + (IS_IPAD ? 30 : 10);
        
        CustomLabel *confirmLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth, 24) withFont:confirmFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ConfirmRemoveQuestion", @"")];
        confirmLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:confirmLabel];
        
        yIndex += 40 + (IS_IPAD ? 20 : 0);
        
        cancelButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2, yIndex, messageWidth/2 - 10, 50) withTitle:NSLocalizedString(@"TitleNo", @"") withBorderColor:[Util UIColorForHexColor:@"e9ebef"] withBgColor:[Util UIColorForHexColor:@"FFFFFF"]];
        [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.isAccessibilityElement = YES;
        cancelButton.accessibilityIdentifier = @"cancelButtonConfirmRemove";
        [self.view addSubview:cancelButton];
        
        confirmButton = [[SimpleButton alloc] initWithFrame:CGRectMake(cancelButton.frame.origin.x + cancelButton.frame.size.width + 20, yIndex, messageWidth/2 - 10, 50) withTitle:NSLocalizedString(@"TitleYes", @"") withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"]];
        [confirmButton addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        confirmButton.isAccessibilityElement = YES;
        confirmButton.accessibilityIdentifier = @"confirmButtonConfirmRemove";
        [self.view addSubview:confirmButton];
        
        yIndex += 68 + (IS_IPAD ? 20 : 0);
        
        checkButton = [[CheckButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - messageWidth)/2 + 20, yIndex, 21, 20) isInitiallyChecked:NO];
        //        [checkButton addTarget:self action:@selector(toggleCheck) forControlEvents:UIControlEventTouchUpInside];
        checkButton.isAccessibilityElement = YES;
        checkButton.accessibilityIdentifier = @"checkButtonConfirmRemove";
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
    [delegate confirmRemoveDidCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) confirmClicked {
    if(checkButton.isChecked) {
        [CacheUtil setConfirmDeletePageFlag];
    }
    [delegate confirmRemoveDidConfirm];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ConfirmRemoveModalController viewDidLoad");
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


@end

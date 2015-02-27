//
//  SettingsController.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppConstants.h"
#import "TitleCell.h"
#import "SettingsStorageController.h"
#import "SettingsUploadController.h"
#import "SettingsConnectedDevicesController.h"
#import "SettingsNotificationsController.h"
#import "SettingsHelpController.h"
#import "SettingsAboutUsController.h"
#import "CustomButton.h"
#import "UIImageView+AFNetworking.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"SettingsTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];
        
        [self drawProfileInfoArea];
        [self drawSettingsCategories];
        //[self drawImageOptionsArea];
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) drawProfileInfoArea {
    UIView *profileInfoArea = [[UIView alloc] initWithFrame:CGRectMake(0, self.topIndex, 320, 159)];
    profileInfoArea.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
    
    UIImage *profileBgImg = [UIImage imageNamed:@"profile_icon"];
    profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 15, 88, 88)];
    profileImageView.image = profileBgImg;
    [profileInfoArea addSubview:profileImageView];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
        UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:APPDELEGATE.session.user.profileImgUrl]]];
        UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17, (60 - profileBgImg.size.height - 2)/2, profileImageView.frame.size.width - 4, profileImageView.frame.size.height - 4)];
        profileImgView.image = [Util circularScaleNCrop:profileImage forRect:CGRectMake(0, 0, 88, 88)];
        profileImgView.center = profileImageView.center;
        [profileInfoArea addSubview:profileImgView];
    });
    
    UIImageView *profileFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 0, 88, 88)];
    UIImage *profileFrameImage = [UIImage imageNamed:@"profile_frame"];
    [profileFrameImageView setImage:profileFrameImage];
//    [profileInfoArea addSubview:profileFrameImageView];
    
    CustomButton *profileButton = [[CustomButton alloc]initWithFrame:CGRectMake(116, 0, 88, 88) withImageName:@"profile_image_button"];
    //[profileButton addTarget:self action:@selector(ShowImageOptionsArea) forControlEvents:UIControlEventTouchUpInside];
    profileButton.userInteractionEnabled = NO;
//    [profileInfoArea addSubview:profileButton];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 118, 300, 20)];
    [nameLabel setText:APPDELEGATE.session.user.fullName];
    nameLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:20];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    nameLabel.backgroundColor= [UIColor clearColor];
    [profileInfoArea addSubview:nameLabel];
    
    /*
    UIImageView *cellPhoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(111, 123, 7, 11)];
    cellPhoneIcon.image = [UIImage imageNamed:@"cellphone_icon@2x"];
    [profileInfoArea addSubview:cellPhoneIcon];
    
    UILabel *phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.5, 119, 190, 20)];
//    [phoneNumberLabel setText:APPDELEGATE.session.user.msisdn];
    phoneNumberLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    phoneNumberLabel.textColor = [Util UIColorForHexColor:@"AFDCF5"];
    phoneNumberLabel.backgroundColor= [UIColor clearColor];
    [profileInfoArea addSubview:phoneNumberLabel];
     */
    
    [self.view addSubview:profileInfoArea];
}

- (void) drawSettingsCategories {
    pageContentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 159, 325, self.view.frame.size.height-self.bottomIndex-159) style:UITableViewStylePlain];
    pageContentTable.delegate = self;
    pageContentTable.dataSource = self;
    pageContentTable.backgroundColor = [UIColor clearColor];
    pageContentTable.backgroundView = nil;
    [pageContentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:pageContentTable];
}

- (void) drawImageOptionsArea {
    popupContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - self.bottomIndex)];
    popupContainer.hidden = YES;
    popupContainer.userInteractionEnabled = YES;
    [self.view addSubview:popupContainer];
    
    darkArea = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, popupContainer.frame.size.height)];
    darkArea.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    [popupContainer addSubview:darkArea];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideImageOptionsArea)];
    [darkArea addGestureRecognizer:singleFingerTap];
    
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    recognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    imageOptionsArea = [[UIView alloc]initWithFrame:CGRectMake(0, popupContainer.frame.size.height, 320, 205)];
    imageOptionsArea.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
    [imageOptionsArea addGestureRecognizer:recognizerDown];
    [popupContainer addSubview:imageOptionsArea];
    
    UIButton *swipeDownButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [imageOptionsArea addSubview:swipeDownButton];
    
    UIImageView *swipeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(128, 0, 64, 16)];
    swipeIcon.image = [UIImage imageNamed:@"slide_icon@2x"];
    [imageOptionsArea addSubview:swipeIcon];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 29, 300, 20)];
    [infoLabel setText:NSLocalizedString(@"EditProfilePicture", @"")];
    infoLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:18];
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    infoLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:infoLabel];
    
    cameraButton = [[CustomButton alloc]initWithFrame:CGRectMake(29, 69, 75, 75) withImageName:@"camera_icon@2x"];
    [cameraButton addTarget:self action:@selector(CameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:cameraButton];
    
    cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 153, 75, 20)];
    [cameraLabel setText:NSLocalizedString(@"Camera", @"")];
    cameraLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    cameraLabel.textAlignment = UITextAlignmentCenter;
    cameraLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    cameraLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:cameraLabel];
    
    uploadButton = [[CustomButton alloc]initWithFrame:CGRectMake(122, 69, 75, 75) withImageName:@"upload_icon@2x"];
    [uploadButton addTarget:self action:@selector(UploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:uploadButton];
    
    uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 153, 75, 20)];
    [uploadLabel setText:NSLocalizedString(@"Upload", @"")];
    uploadLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    uploadLabel.textAlignment = UITextAlignmentCenter;
    uploadLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    uploadLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:uploadLabel];
    
    removeButton = [[CustomButton alloc]initWithFrame:CGRectMake(215, 69, 75, 75) withImageName:@"remove_icon@2x"];
    [removeButton addTarget:self action:@selector(RemoveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:removeButton];
    
    removeLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 153, 75, 20)];
    [removeLabel setText:NSLocalizedString(@"Remove", @"")];
    removeLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    removeLabel.textAlignment = UITextAlignmentCenter;
    removeLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    removeLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:removeLabel];
}

- (void)swipeDown:(UISwipeGestureRecognizer*)recognizer {
    [self HideImageOptionsArea];
}

- (void)CameraButtonAction: (id)sender {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.showsCameraControls = YES;
    imagePicker.wantsFullScreenLayout = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    [self HideImageOptionsArea];
}

- (void)UploadButtonAction: (id)sender {
    if (imagePicker == nil)
        imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    [self HideImageOptionsArea];
}

- (void)RemoveButtonAction: (id)sender {
    [self HideImageOptionsArea];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *choosenImage = info[UIImagePickerControllerEditedImage];
    
    // Resize Image
    CGSize newSize = CGSizeMake(480, 480);
    UIGraphicsBeginImageContext(newSize);
    [choosenImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    BOOL drawSeparator = indexPath.section == 4 ? false : true;
    double cellHeight = 69;
    
    if(indexPath.row == 0) {
        NSString *subTitle = [NSString stringWithFormat: NSLocalizedString(@"StorageUsageInfo", @""), [NSString stringWithFormat:@"%.0lld", (100 * APPDELEGATE.session.usage.usedStorage/APPDELEGATE.session.usage.totalStorage)], [Util transformedHugeSizeValue:APPDELEGATE.session.usage.totalStorage]];
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Memory", @"") titleColor:nil subTitleText:subTitle iconName:@"stroge_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if (indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"AutomaticSynchronization", @"") titleColor:nil subTitleText:@"" iconName:@"syncing_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if (indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ConnectedDevices", @"") titleColor:nil subTitleText:@"" iconName:@"device_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if (indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"HowTo", @"") titleColor:nil subTitleText:@"" iconName:@"info_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if (indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"FAQ", @"") titleColor:nil subTitleText:@"" iconName:@"help_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 0:
            [self didTriggerStorage];
            break;
        case 1:
            [self didTriggerUpload];
            break;
        case 2:
            [self didTriggerConnectedDevices];
            break;
        case 3:
            [self didTriggerAboutUs];
            break;
        case 4:
            [self didTriggerHelp];
            break;
        default:
            break;
    }
}

- (void) ShowImageOptionsArea {
    int buttonCount = 2;//newProfileImage == nil ? 2 : 3;
    float leftIndex = (320 - (buttonCount * 75 + (buttonCount - 1) * 18)) / 2;
    
    cameraButton.frame = CGRectMake(leftIndex, cameraButton.frame.origin.y, 75, 75);
    cameraLabel.frame = CGRectMake(leftIndex, cameraLabel.frame.origin.y, 75, 20);
    uploadButton.frame = CGRectMake(leftIndex + 93, uploadButton.frame.origin.y, 75, 75);
    uploadLabel.frame = CGRectMake(leftIndex + 93, uploadLabel.frame.origin.y, 75, 20);
    if (buttonCount > 2) {
        removeButton.frame = CGRectMake(leftIndex + 186, removeButton.frame.origin.y, 75, 75);
        removeLabel.frame = CGRectMake(leftIndex + 186, removeLabel.frame.origin.y, 75, 20);
        removeButton.hidden = NO;
        removeLabel.hidden = NO;
    }
    else {
        removeButton.hidden = YES;
        removeLabel.hidden = YES;
    }
    
    popupContainer.hidden = NO;
    darkArea.alpha = 0;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        imageOptionsArea.frame = CGRectMake(0, popupContainer.frame.size.height - 205, imageOptionsArea.frame.size.width, imageOptionsArea.frame.size.height);
        darkArea.alpha = 0.85;
    } completion:^(BOOL finished) {
    }];
}

- (void) HideImageOptionsArea {
    [UIView animateWithDuration:0.3
                          delay:0
    options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        imageOptionsArea.frame = CGRectMake(0, popupContainer.frame.size.height, imageOptionsArea.frame.size.width, imageOptionsArea.frame.size.height);
        darkArea.alpha = 0.0;
    } completion:^(BOOL finished) {
        popupContainer.hidden = YES;
        darkArea.alpha = 0.85;
    }];
}

- (void) didTriggerStorage {
    SettingsStorageController *storageController = [[SettingsStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
}

- (void) didTriggerUpload {
    SettingsUploadController *uploadController = [[SettingsUploadController alloc] init];
    uploadController.nav = self.nav;
    [self.nav pushViewController:uploadController animated:YES];
}

- (void) didTriggerConnectedDevices {
    SettingsConnectedDevicesController *connectedDevicesController = [[SettingsConnectedDevicesController alloc] init];
    connectedDevicesController.nav = self.nav;
    [self.nav pushViewController:connectedDevicesController animated:YES];
}
/*
- (void) didTriggerNotifications {
    SettingsNotificationsController *notificationsController = [[SettingsNotificationsController alloc] init];
    notificationsController.nav = self.nav;
    [self.nav pushViewController:notificationsController animated:YES];
}
*/
- (void) didTriggerHelp {
    SettingsHelpController *helpController = [[SettingsHelpController alloc] init];
    helpController.nav = self.nav;
    [self.nav pushViewController:helpController animated:YES];
}

- (void) didTriggerAboutUs {
    SettingsAboutUsController *aboutUsController = [[SettingsAboutUsController alloc] init];
    aboutUsController.nav = self.nav;
    [self.nav pushViewController:aboutUsController animated:YES];
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

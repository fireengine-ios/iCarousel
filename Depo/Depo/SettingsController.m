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
#import "RevisitedStorageController.h"

#import "SettingsUploadController.h"
#import "SettingsConnectedDevicesController.h"
#import "SettingsNotificationsController.h"
#import "SettingsHelpController.h"
#import "SettingsAboutUsController.h"
#import "CustomButton.h"
#import "UIImageView+AFNetworking.h"
#import "ChangePassController.h"
#import "UpdateMsisdnController.h"
#import "MPush.h"
#import "DropboxExportController.h"
#import "EmailChangeController.h"
#import "SettingsSocialController.h"
#import "RecentActivitiesController.h"
#import "BaseViewController.h"
#include <math.h>

@interface SettingsController () {
    UILabel *msisdnLabel;
    UIImageView *profileImgView;
    UIImage *updatedImageRef;
}
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

        uploadDao = [[ProfilePhotoUploadDao alloc] init];
        uploadDao.delegate = self;
        uploadDao.successMethod = @selector(photoUploadSuccess);
        uploadDao.failMethod = @selector(photoUploadFail:);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retouchMsisdn) name:MSISDN_CHANGED_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void) retouchMsisdn {
    [msisdnLabel setText:APPDELEGATE.session.user.phoneNumber];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) drawProfileInfoArea {
    UIView *profileInfoArea = [[UIView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.width/2)];
    profileInfoArea.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
    
    float imageWidth = profileInfoArea.frame.size.width * 0.275f;

    UIImage *profileBgImg = [UIImage imageNamed:@"profile_icon"];
    profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake((profileInfoArea.frame.size.width - imageWidth)/2, (profileInfoArea.frame.size.height - imageWidth)/2 - 20, imageWidth, imageWidth)];
    profileImageView.image = profileBgImg;
    [profileImageView setUserInteractionEnabled:YES];
    [profileInfoArea addSubview:profileImageView];

    if(APPDELEGATE.session.profileImageRef) {
        profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, profileImageView.frame.size.width - 4, profileImageView.frame.size.height - 4)];
        profileImgView.image = [Util circularScaleNCrop:APPDELEGATE.session.profileImageRef forRect:CGRectMake(0, 0, profileImageView.frame.size.width - 4, profileImageView.frame.size.width - 4)];
        profileImgView.center = profileImageView.center;
        [profileInfoArea addSubview:profileImgView];

        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        imageTap.enabled = YES;
        imageTap.numberOfTapsRequired = 1;
        [profileImageView addGestureRecognizer:imageTap];
    }
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
        UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:APPDELEGATE.session.user.profileImgUrl]]];
        UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17, (60 - profileBgImg.size.height - 2)/2, profileImageView.frame.size.width - 4, profileImageView.frame.size.height - 4)];
        profileImgView.image = [Util circularScaleNCrop:profileImage forRect:CGRectMake(0, 0, 88, 88)];
        profileImgView.center = profileImageView.center;
        [profileInfoArea addSubview:profileImgView];
    });
     */
    
    UIImageView *profileFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(116, 0, 88, 88)];
    UIImage *profileFrameImage = [UIImage imageNamed:@"profile_frame"];
    [profileFrameImageView setImage:profileFrameImage];
//    [profileInfoArea addSubview:profileFrameImageView];
    
    CustomButton *profileButton = [[CustomButton alloc]initWithFrame:CGRectMake(116, 0, 88, 88) withImageName:@"profile_image_button"];
    //[profileButton addTarget:self action:@selector(ShowImageOptionsArea) forControlEvents:UIControlEventTouchUpInside];
    profileButton.userInteractionEnabled = NO;
//    [profileInfoArea addSubview:profileButton];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, profileImageView.frame.origin.y + profileImageView.frame.size.height + (IS_IPAD ? 20 : 5), self.view.frame.size.width - 20, IS_IPAD ? 30 : 20)];
    if(APPDELEGATE.session.user.email) {
        [nameLabel setText:APPDELEGATE.session.user.email];
    } else {
        [nameLabel setText:APPDELEGATE.session.user.fullName];
    }
    nameLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:(IS_IPAD ? 30 : 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    nameLabel.backgroundColor= [UIColor clearColor];
    [profileInfoArea addSubview:nameLabel];

    NSString *msisdnVal = APPDELEGATE.session.user.phoneNumber;
    UIFont *msisdnFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:(IS_IPAD ? 30 : 20)];
    
    float msisdnWidth = [Util calculateWidthForText:msisdnVal forHeight:(IS_IPAD ? 30 : 20) forFont:msisdnFont] + 10;
    
    msisdnLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - msisdnWidth)/2 + 10, nameLabel.frame.origin.y + nameLabel.frame.size.height + (IS_IPAD ? 10 : 4), msisdnWidth, (IS_IPAD ? 30 : 20))];
    [msisdnLabel setText:msisdnVal];
    msisdnLabel.font = msisdnFont;
    msisdnLabel.textAlignment = NSTextAlignmentCenter;
    msisdnLabel.textColor = [Util UIColorForHexColor:@"bce3f7"];
    msisdnLabel.backgroundColor= [UIColor clearColor];
    [msisdnLabel setUserInteractionEnabled:YES];
    [profileInfoArea addSubview:msisdnLabel];

    UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(msisdnClicked)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.enabled = YES;
    [msisdnLabel addGestureRecognizer:singleTapGesture];

    UIImage *editIcon = [UIImage imageNamed:@"icon_editnum.png"];
    UIImageView *editIconView = [[UIImageView alloc] initWithFrame:CGRectMake(msisdnLabel.frame.origin.x - 17, msisdnLabel.frame.origin.y, 14, 14)];
    editIconView.image = editIcon;
    [profileInfoArea addSubview:editIconView];

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

- (void) msisdnClicked {
    if(APPDELEGATE.session.user.accountType == AccountTypeOther) {
        UpdateMsisdnController *updateMsisdn = [[UpdateMsisdnController alloc] init];
        updateMsisdn.nav = self.nav;
        [self.nav pushViewController:updateMsisdn animated:YES];
    }
}

- (void) drawSettingsCategories {
    pageContentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + self.view.frame.size.width/2, self.view.frame.size.width, self.view.frame.size.height-self.bottomIndex-self.view.frame.size.width/2) style:UITableViewStyleGrouped];
    pageContentTable.delegate = self;
    pageContentTable.dataSource = self;
    pageContentTable.backgroundColor = [UIColor clearColor];
    pageContentTable.backgroundView = nil;
    [pageContentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    pageContentTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, pageContentTable.bounds.size.width, 0.01f)];
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
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    infoLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:infoLabel];
    
    cameraButton = [[CustomButton alloc]initWithFrame:CGRectMake(29, 69, 75, 75) withImageName:@"camera_icon@2x"];
    [cameraButton addTarget:self action:@selector(CameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:cameraButton];
    
    cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 153, 75, 20)];
    [cameraLabel setText:NSLocalizedString(@"Camera", @"")];
    cameraLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    cameraLabel.textAlignment = NSTextAlignmentCenter;
    cameraLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    cameraLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:cameraLabel];
    
    uploadButton = [[CustomButton alloc]initWithFrame:CGRectMake(122, 69, 75, 75) withImageName:@"upload_icon@2x"];
    [uploadButton addTarget:self action:@selector(UploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:uploadButton];
    
    uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 153, 75, 20)];
    [uploadLabel setText:NSLocalizedString(@"Upload", @"")];
    uploadLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    uploadLabel.textAlignment = NSTextAlignmentCenter;
    uploadLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    uploadLabel.backgroundColor= [UIColor clearColor];
    [imageOptionsArea addSubview:uploadLabel];
    
    removeButton = [[CustomButton alloc]initWithFrame:CGRectMake(215, 69, 75, 75) withImageName:@"remove_icon@2x"];
    [removeButton addTarget:self action:@selector(RemoveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:removeButton];
    
    removeLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 153, 75, 20)];
    [removeLabel setText:NSLocalizedString(@"Remove", @"")];
    removeLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    removeLabel.textAlignment = NSTextAlignmentCenter;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#ifdef LOG2FILE
    return 9;
#else
    return 8;
#endif
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IS_IPAD) {
        return 102;
    } else {
        return 69;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    CustomLabel *versionLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 10, footerView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"565656"] withText:[NSString stringWithFormat:@"v. %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] withAlignment:NSTextAlignmentCenter];
    [footerView addSubview:versionLabel];
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    BOOL drawSeparator = indexPath.section == 4 ? false : true;
    double cellHeight = 69;
    
    if(indexPath.row == 0) {
        NSLog(@"USAGE:%lld and %lld", APPDELEGATE.session.usage.usedStorage, APPDELEGATE.session.usage.totalStorage);
        double percentUsageVal = 100 * ((double)APPDELEGATE.session.usage.usedStorage/(double)APPDELEGATE.session.usage.totalStorage);
        percentUsageVal = isnan(percentUsageVal) ? 0 : (percentUsageVal > 0 && percentUsageVal < 1) ? 1 : percentUsageVal;
        NSString *subTitle = [NSString stringWithFormat: NSLocalizedString(@"StorageUsageInfo", @""), [NSString stringWithFormat:@"%d", (int)floor(percentUsageVal+0.5f)], [Util transformedHugeSizeValueDecimalIfNecessary:APPDELEGATE.session.usage.totalStorage]];
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Packages", @"") titleColor:nil subTitleText:subTitle iconName:@"stroge_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"AutomaticSynchronization", @"") titleColor:nil subTitleText:@"" iconName:@"syncing_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"RecentActivityLinkerTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_hp_sonislemler.png" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ConnectedDevices", @"") titleColor:nil subTitleText:@"" iconName:@"device_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
//    } else if (indexPath.row == 3) {
//        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"PasswordSettingsTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_set_pass" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
//        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
//        return cell;
    } else if (indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"EmailTitle", @"") titleColor:nil subTitleText:@"" iconName:@"email_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 5) {
//        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ExportFromDropbox", @"") titleColor:nil subTitleText:@"" iconName:@"icon_dbtasi" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ExportFromDropbox", @"") titleColor:nil subTitleText:@"" iconName:@"nav_download_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 6) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"SocialMediaTitle", @"") titleColor:nil subTitleText:@"" iconName:@"icon_sm.png" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 7) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"FAQ", @"") titleColor:nil subTitleText:@"" iconName:@"help_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        return cell;
    } else if (indexPath.row == 8) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Mail Logs" titleColor:nil subTitleText:@"" iconName:@"help_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
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
            [self didTriggerRecentActivities];
            break;
        case 3:
            [self didTriggerConnectedDevices];
            break;
//        case 3:
//            [self didTriggerPass];
//            break;
        case 4:
            [self didTriggerEmail];
            break;
        case 5:
            [self didTriggerExportFromDropbox];
            break;
        case 6:
            [self didTriggerExportFromSocial];
            break;
        case 7:
            [self didTriggerHelp];
            break;
        case 8:
            [self triggerMailLog];
            break;
        default:
            break;
    }
}

- (void) triggerMailLog {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@"Device Logs"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"mahirtarlan@gmail.com"]];
        [mailCont setMessageBody:@"Latest device logs are attached" isHTML:NO];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"nslogs.log"];
        NSData *logData = [NSData dataWithContentsOfFile:logPath];
        
        [mailCont addAttachmentData:logData mimeType:@"text/plain" fileName:@"logs.txt"];

        [self presentViewController:mailCont animated:YES completion:nil];
    }
}
    
- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"nslogs.log"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logPath error:nil];
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
    [MPush hitTag:@"packages"];
    [MPush hitEvent:@"packages"];

    RevisitedStorageController *storageController = [[RevisitedStorageController alloc] init];
    storageController.nav = self.nav;
    [self.nav pushViewController:storageController animated:YES];
}

- (void) didTriggerUpload {
    SettingsUploadController *uploadController = [[SettingsUploadController alloc] init];
    uploadController.nav = self.nav;
    [self.nav pushViewController:uploadController animated:YES];
}

- (void) didTriggerRecentActivities {
    [APPDELEGATE.base showRecentActivities];
}

- (void) didTriggerConnectedDevices {
    [MPush hitTag:@"connected_devices"];
    [MPush hitEvent:@"connected_devices"];

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

- (void) didTriggerEmail {
    EmailChangeController *emailController = [[EmailChangeController alloc] init];
    emailController.nav = self.nav;
    [self.nav pushViewController:emailController animated:YES];
}

- (void) didTriggerExportFromDropbox {
    DropboxExportController *dbController = [[DropboxExportController alloc] init];
    dbController.nav = self.nav;
    [self.nav pushViewController:dbController animated:YES];
}

- (void) didTriggerExportFromSocial {
    SettingsSocialController *socialController = [[SettingsSocialController alloc] init];
    socialController.nav = self.nav;
    [self.nav pushViewController:socialController animated:YES];
}

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

- (void) didTriggerPass {
    ChangePassController *changePass = [[ChangePassController alloc] init];
    changePass.nav = self.nav;
    [self.nav pushViewController:changePass animated:YES];
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

- (void) imageTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ButtonCancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhoto", @""), NSLocalizedString(@"ChooseFromLibrary", @""), nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 1: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage;
    NSURL *mediaUrl;
    mediaUrl = (NSURL *)[info valueForKey:UIImagePickerControllerMediaURL];
    if(mediaUrl == nil) {
        selectedImage = (UIImage *) [info valueForKey:UIImagePickerControllerEditedImage];
        if(selectedImage == nil) {
            selectedImage= (UIImage *) [info valueForKey:UIImagePickerControllerOriginalImage];
        }
    }
    if(selectedImage) {
        updatedImageRef = selectedImage;
        [uploadDao requestUploadForImage:selectedImage];
        [self showLoading];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) photoUploadSuccess {
    [self hideLoading];
    [self showInfoAlertWithMessage:NSLocalizedString(@"ProfilePhotoUploadSuccess", @"")];

    APPDELEGATE.session.profileImageRef = updatedImageRef;
    profileImgView.image = [Util circularScaleNCrop:APPDELEGATE.session.profileImageRef forRect:CGRectMake(0, 0, profileImageView.frame.size.width - 4, profileImageView.frame.size.width - 4)];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROFILE_IMG_UPLOADED_NOTIFICATION object:nil];
}

- (void) photoUploadFail:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

@end

//
//  SettingsController.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate.h"
#import "AppConstants.h"
#import "TitleCell.h"
#import "SettingsStorageController.h"
#import "SettingsUploadController.h"
#import "SettingsConnectedDevicesController.h"
#import "SettingsNotificationsController.h"
#import "SettingsHelpController.h"
#import "CustomButton.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = @"Settings";
        [self drawProfileInfoArea];
        [self drawSettingsCategories];
        [self drawImageOptionsArea];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) drawProfileInfoArea {
    UIView *profileInfoArea = [[UIView alloc] initWithFrame:CGRectMake(0, self.topIndex, 320, 203)];
    profileInfoArea.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
    
    CustomButton *profileImage = [[CustomButton alloc]initWithFrame:CGRectMake(120, 50, 80, 80) withImageName:@"profile_icon@2x"];
    [profileImage addTarget:self action:@selector(ShowImageOptionsArea:) forControlEvents:UIControlEventTouchUpInside];
    [profileInfoArea addSubview:profileImage];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 20)];
    [nameLabel setText:@"Memet Emanetoğlu"];
    nameLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:20];
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    [profileInfoArea addSubview:nameLabel];
    
    UIImageView *cellPhoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(111, 165.5, 7, 11)];
    cellPhoneIcon.image = [UIImage imageNamed:@"cellphone_icon@2x"];
    [profileInfoArea addSubview:cellPhoneIcon];
    
    UILabel *phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(122.5, 161, 190, 20)];
    [phoneNumberLabel setText:@"05555022460"];
    phoneNumberLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    phoneNumberLabel.textColor = [Util UIColorForHexColor:@"AFDCF5"];
    [profileInfoArea addSubview:phoneNumberLabel];
    
    [self.view addSubview:profileInfoArea];
}

- (void) drawSettingsCategories {
    pageContentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 203, 325, self.view.frame.size.height-self.bottomIndex-203) style:UITableViewStylePlain];
    pageContentTable.delegate = self;
    pageContentTable.dataSource = self;
    pageContentTable.backgroundColor = [UIColor clearColor];
    pageContentTable.backgroundView = nil;
    [pageContentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:pageContentTable];
}

- (void) drawImageOptionsArea {
    popupContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    popupContainer.hidden = YES;
    popupContainer.userInteractionEnabled = YES;
    [self.view addSubview:popupContainer];
    
    darkArea = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, popupContainer.frame.size.height)];
    darkArea.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    [popupContainer addSubview:darkArea];
    
    imageOptionsArea = [[UIView alloc]initWithFrame:CGRectMake(0, popupContainer.frame.size.height, 320, 205)];
    imageOptionsArea.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
    [popupContainer addSubview:imageOptionsArea];
    
    UIButton *swipeDownButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [imageOptionsArea addSubview:swipeDownButton];
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    recognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:recognizerDown];
    [imageOptionsArea addSubview:swipeDownButton];
    
    UIImageView *swipeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(143, 7, 34, 7)];
    swipeIcon.image = [UIImage imageNamed:@"menu_icon@2x"];
    [imageOptionsArea addSubview:swipeIcon];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 29, 300, 20)];
    [infoLabel setText:@"Edit Profile Picture"];
    infoLabel.font = [UIFont fontWithName:@"TurkcellSaturaBol" size:18];
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    [imageOptionsArea addSubview:infoLabel];
    
    CustomButton *cameraButton = [[CustomButton alloc]initWithFrame:CGRectMake(29, 69, 75, 75) withImageName:@"camera_icon@2x"];
    [cameraButton addTarget:self action:@selector(HideImageOptionsArea:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:cameraButton];
    
    UILabel *cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 153, 75, 20)];
    [cameraLabel setText:@"Camera"];
    cameraLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    cameraLabel.textAlignment = UITextAlignmentCenter;
    cameraLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    [imageOptionsArea addSubview:cameraLabel];
    
    CustomButton *uploadButton = [[CustomButton alloc]initWithFrame:CGRectMake(122, 69, 75, 75) withImageName:@"upload_icon@2x"];
    [uploadButton addTarget:self action:@selector(HideImageOptionsArea:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:uploadButton];
    
    UILabel *uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 153, 75, 20)];
    [uploadLabel setText:@"Upload"];
    uploadLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    uploadLabel.textAlignment = UITextAlignmentCenter;
    uploadLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    [imageOptionsArea addSubview:uploadLabel];
    
    CustomButton *removeButton = [[CustomButton alloc]initWithFrame:CGRectMake(215, 69, 75, 75) withImageName:@"remove_icon@2x"];
    [removeButton addTarget:self action:@selector(HideImageOptionsArea:) forControlEvents:UIControlEventTouchUpInside];
    [imageOptionsArea addSubview:removeButton];
    
    UILabel *removeLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 153, 75, 20)];
    [removeLabel setText:@"Remove"];
    removeLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
    removeLabel.textAlignment = UITextAlignmentCenter;
    removeLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
    [imageOptionsArea addSubview:removeLabel];
}

- (void)swipeDown:(UISwipeGestureRecognizer*)recognizer {
    [self HideImageOptionsArea: imageOptionsArea];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == -1)
        return 203;
    else
        return 69;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    BOOL drawSeparator = indexPath.section == 4 ? false : true;
    double cellHeight = 69;
    
    if(indexPath.section == 0) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Storage" titleColor:nil subTitleText:@"20% of 5GB" iconName:@"stroge_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if(indexPath.section == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Upload & Syncing" titleColor:nil subTitleText:@"" iconName:@"syncing_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if(indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Connected Devices" titleColor:nil subTitleText:@"" iconName:@"device_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if(indexPath.section == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Notifications" titleColor:nil subTitleText:@"" iconName:@"notifications_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else if(indexPath.section == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Help" titleColor:nil subTitleText:@"" iconName:@"help_icon" hasSeparator:drawSeparator isLink:YES linkText:@"" cellHeight:cellHeight];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
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
            [self didTriggerNotifications];
            break;
        case 4:
            [self didTriggerHelp];
            break;
        default:
            break;
    }
}



- (void) ShowImageOptionsArea: (id)sender {
    popupContainer.hidden = NO;
    darkArea.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        imageOptionsArea.frame = CGRectMake(0, popupContainer.frame.size.height - 205, imageOptionsArea.frame.size.width, imageOptionsArea.frame.size.height);
        darkArea.alpha = 0.85;
    } completion:^(BOOL finished) {
    }];
}

- (void) HideImageOptionsArea: (id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        imageOptionsArea.frame = CGRectMake(0, 568, imageOptionsArea.frame.size.width, imageOptionsArea.frame.size.height);
        darkArea.alpha = 0.0;
    } completion:^(BOOL finished) {
        popupContainer.hidden = YES;
        darkArea.alpha = 0.85;
    }];
}

- (void) didTriggerStorage {
    SettingsStorageController  *storageController = [[SettingsStorageController alloc] init];
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

- (void) didTriggerNotifications {
    SettingsNotificationsController *notificationsController = [[SettingsNotificationsController alloc] init];
    notificationsController.nav = self.nav;
    [self.nav pushViewController:notificationsController animated:YES];
}

- (void) didTriggerHelp {
    SettingsHelpController *helpController = [[SettingsHelpController alloc] init];
    helpController.nav = self.nav;
    [self.nav pushViewController:helpController animated:YES];
}

@end

//
//  SettingsController.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "TitleCell.h"
#import "CacheUtil.h"
#import <MessageUI/MessageUI.h>

@interface SettingsController : MyViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
    UIImageView *profileImageView;
    UITableView *pageContentTable;
    UIView *imageOptionsArea;
    UIView *darkArea;
    UIView *popupContainer;
    UIImagePickerController *imagePicker;
    CustomButton *cameraButton;
    UILabel *cameraLabel;
    CustomButton *uploadButton;
    UILabel *uploadLabel;
    CustomButton *removeButton;
    UILabel *removeLabel;
}

@end

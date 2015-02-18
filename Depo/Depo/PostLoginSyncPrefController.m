//
//  PostLoginSyncPrefController.m
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginSyncPrefController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "PostLoginPrefCell.h"
#import "CacheUtil.h"
#import "AppUtil.h"
#import <AddressBookUI/AddressBookUI.h>

@interface PostLoginSyncPrefController ()

@end

@implementation PostLoginSyncPrefController

@synthesize onOff1, onOff2;
@synthesize choiceTable;
@synthesize choices;
@synthesize selectedOption;
@synthesize assetsLibrary;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        choices = [[NSMutableArray alloc] init];
        [choices addObject:@"Wifi + 3G"];
        [choices addObject:@"Wifi"];
        selectedOption = ConnectionOptionWifi3G;
        
        UIFont *descFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:18];
        
        UIImage *syncImg = [UIImage imageNamed:@"sync_prefs.png"];
        
        UIImageView *syncImgView = [[UIImageView alloc] init];
        if (IS_IPHONE_5)
            syncImgView.frame = CGRectMake((self.view.frame.size.width - syncImg.size.width)/2, 50, syncImg.size.width, syncImg.size.height);
        else
            syncImgView.frame = CGRectMake((self.view.frame.size.width - (syncImg.size.width - 120))/2, 50, syncImg.size.width - 120, syncImg.size.height - 75);
        
        syncImgView.image = syncImg;
        [self.view addSubview:syncImgView];
        
        CustomLabel *mainTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 15, self.view.frame.size.width - 40, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:13] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"PostLoginSyncPrefTitle", @"")];
        [self.view addSubview:mainTitleLabel];
        
        CustomLabel *switchLabel1 = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 40, 230, 40) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"SyncPhotoVideoTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel1.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel1];
        
        onOff1 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, syncImgView.frame.origin.y + syncImgView.frame.size.height + 45, 40, 40)];
        [onOff1 setOn:YES];
        [onOff1 addTarget:self action:@selector(onOffChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:onOff1];
        
        CustomLabel *switchLabel2 = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 85, 230, 40) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"SyncContactsTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel2.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel2];
        
        onOff2 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, syncImgView.frame.origin.y + syncImgView.frame.size.height + 90, 40, 40)];
        [onOff2 setOn:YES];
        [onOff2 addTarget:self action:@selector(onOffChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:onOff2];
        
        choiceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, syncImgView.frame.origin.y + syncImgView.frame.size.height + 140, self.view.frame.size.width, 80) style:UITableViewStylePlain];
        choiceTable.delegate = self;
        choiceTable.dataSource = self;
        choiceTable.bounces = NO;
        [self.view addSubview:choiceTable];

        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [continueButton addTarget:self action:@selector(continueClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:continueButton];
    }
    return self;
}

- (void)onOffChanged:(id)sender
{
    if (![onOff1 isOn] && ![onOff2 isOn])
        choiceTable.hidden = YES;
    else
        choiceTable.hidden = NO;
}

- (void) continueClicked {
    if(onOff1.isOn) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group == nil) {
                [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOn];
            }
        } failureBlock:^(NSError *error) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
        }];
    } else {
        [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
    }
    
    if(onOff2.isOn) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) { } else { }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) { }
        else { }
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOn];
    } else {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
    }
    
    [CacheUtil writeCachedSettingSyncingConnectionType:selectedOption];
    [CacheUtil writeCachedSettingDataRoaming:NO];

    [AppUtil writeFirstVisitOverFlag];
    [APPDELEGATE triggerHome];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [choices count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"PREF_CELL_%d", (int) indexPath.row];
    PostLoginPrefCell *cell = [[PostLoginPrefCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTitle:[choices objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        selectedOption = ConnectionOptionWifi3G;
    } else {
        selectedOption = ConnectionOptionWifi;
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

@end

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

@synthesize autoSyncSwitch;
@synthesize choiceTitleLabel;
@synthesize choiceTable;
@synthesize choices;
@synthesize selectedOption;
@synthesize assetsLibrary;
@synthesize wifi3gCell;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        choices = [[NSMutableArray alloc] init];
        [choices addObject:@"Wifi + 3G"];
        [choices addObject:@"Wifi"];
        selectedOption = ConnectionOptionWifi3G;
        
        UIFont *descFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:16];
        
        UIImage *syncImg = [UIImage imageNamed:@"sync_prefs.png"];
        
        UIImageView *syncImgView = [[UIImageView alloc] init];
        if (IS_IPHONE_5)
            syncImgView.frame = CGRectMake((self.view.frame.size.width - syncImg.size.width)/2, 50, syncImg.size.width, syncImg.size.height);
        else
            syncImgView.frame = CGRectMake((self.view.frame.size.width - (syncImg.size.width - 120))/2, 40, syncImg.size.width - 120, syncImg.size.height - 75);
        
        syncImgView.image = syncImg;
        [self.view addSubview:syncImgView];
        
        NSString *descStr = NSLocalizedString(@"PostLoginSyncInfo", @"");
        int descHeight = [Util calculateHeightForText:descStr forWidth:self.view.frame.size.width-40 forFont:descFont] + 5;
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 10, self.view.frame.size.width - 40, descHeight) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:descStr withAlignment:NSTextAlignmentCenter];
        descLabel.numberOfLines = 0;
        [self.view addSubview:descLabel];
        
        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 75, 230, 40) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"AutoSyncTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        autoSyncSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, syncImgView.frame.origin.y + syncImgView.frame.size.height + 80, 40, 40)];
        [autoSyncSwitch setOn:YES];
        [autoSyncSwitch addTarget:self action:@selector(autoSyncSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:autoSyncSwitch];
        
        choiceTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 120, self.view.frame.size.width - 40, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:13] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"PostLoginSyncPrefTitle", @"")];
        [self.view addSubview:choiceTitleLabel];
        
        choiceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, syncImgView.frame.origin.y + syncImgView.frame.size.height + 145, self.view.frame.size.width, 80) style:UITableViewStylePlain];
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

- (void)autoSyncSwitchChanged:(id)sender
{
    if (![autoSyncSwitch isOn]) {
        [self fadeOut:choiceTable duration:0.1];
        [self fadeOut:choiceTitleLabel duration:0.1];
    } else {
        [self fadeIn:choiceTable duration:0.1];
        [self fadeIn:choiceTitleLabel duration:0.1];
    }
}

- (void) continueClicked {
    if(autoSyncSwitch.isOn) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        } failureBlock:^(NSError *error) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
        }];
        
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) { } else { }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) { }
        else { }

        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOn];
        [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOn];
    
    } else {
        [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
    }
    
    [CacheUtil writeCachedSettingSyncingConnectionType:selectedOption];
    [CacheUtil writeCachedSettingDataRoaming:NO];

    [AppUtil writeFirstVisitOverFlag];
//    [APPDELEGATE triggerHome];
    [APPDELEGATE startOpeningPage];
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
    if (indexPath.row == 0) {
        wifi3gCell = cell;
    }
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // ios7'de ilk seçeneğin seçili olarak gelmesi için eklendi
    [wifi3gCell setSelected:YES animated:NO];
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

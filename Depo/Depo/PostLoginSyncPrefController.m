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
#import "CurioSDK.h"
#import "MPush.h"

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
@synthesize locInfoPopup;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        choices = [[NSMutableArray alloc] init];
        [choices addObject:@"Wifi + 3G + 4.5G"];
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
        
        TTTAttributedLabel *descLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 5, self.view.frame.size.width - 40, descHeight)];
        descLabel.font = descFont;
        descLabel.frame = CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 5, self.view.frame.size.width - 40, descHeight);
        descLabel.delegate = self;
        descLabel.textColor = [Util UIColorForHexColor:@"FFFFFF"];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descLabel.numberOfLines = 0;
        descLabel.text = descStr;
        [self.view addSubview:descLabel];
        
        NSRange faqRange = [descStr rangeOfString:@"For details"];
        if(faqRange.location == NSNotFound) {
            faqRange = [descStr rangeOfString:@"Detaylı bilgi"];
        }
        [descLabel addLinkToURL:[NSURL URLWithString:@"action://show-faq"] withRange:faqRange];
        
        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 80, 230, 40) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"AutoSyncTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        autoSyncSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, syncImgView.frame.origin.y + syncImgView.frame.size.height + 85, 40, 40)];
        [autoSyncSwitch setOn:YES];
        [autoSyncSwitch addTarget:self action:@selector(autoSyncSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:autoSyncSwitch];
        
        choiceTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 125, self.view.frame.size.width - 40, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:13] withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"PostLoginSyncPrefTitle", @"")];
        [self.view addSubview:choiceTitleLabel];
        
        choiceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, syncImgView.frame.origin.y + syncImgView.frame.size.height + 145, self.view.frame.size.width, 80) style:UITableViewStylePlain];
        choiceTable.delegate = self;
        choiceTable.dataSource = self;
        choiceTable.bounces = NO;
        [self.view addSubview:choiceTable];
        
        CGRect continueButtonRect = CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50);
        
        if(IS_IPAD) {
            float yTopIndexForIpad = (self.view.frame.size.height - 600)/2;
            float widthForIpad = self.view.frame.size.width > 400 ? 400 : self.view.frame.size.width;
            float xLeftIndexForIpad = (self.view.frame.size.width - widthForIpad)/2;
            
            if(yTopIndexForIpad < 20) {
                yTopIndexForIpad = 20;
            }
            
            syncImgView.frame = CGRectMake(xLeftIndexForIpad + (widthForIpad - syncImg.size.width)/2, yTopIndexForIpad, syncImg.size.width, syncImg.size.height);
            
            descHeight = [Util calculateHeightForText:descStr forWidth:widthForIpad-40 forFont:descFont] + 5;
            descLabel.frame = CGRectMake(xLeftIndexForIpad + 20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 5, widthForIpad-40, descHeight);
            switchLabel.frame = CGRectMake(xLeftIndexForIpad + 20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 80, 230, 40);
            autoSyncSwitch.frame = CGRectMake(xLeftIndexForIpad + widthForIpad - 40, syncImgView.frame.origin.y + syncImgView.frame.size.height + 85, 40, 40);
            choiceTitleLabel.frame = CGRectMake(xLeftIndexForIpad + 20, syncImgView.frame.origin.y + syncImgView.frame.size.height + 125, widthForIpad - 40, 15);
            choiceTable.frame = CGRectMake(xLeftIndexForIpad, syncImgView.frame.origin.y + syncImgView.frame.size.height + 145, widthForIpad, 80);
            continueButtonRect = CGRectMake(xLeftIndexForIpad, choiceTable.frame.origin.y + choiceTable.frame.size.height + 30, widthForIpad, 50);
        }
        
        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:continueButtonRect withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
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
    [self showLocInfoPopup];
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

#pragma mark LocationManagerDelegate methods

- (void) locationPermissionDenied {
    /*
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LocationNotEnabled", @"") withModalType:ModalTypeError];
    alert.delegate = self;
    [APPDELEGATE showCustomAlert:alert];
    
    [LocationManager sharedInstance].delegate = nil;
     */
    [AppUtil resetLocInfoPopupShownFlag];
    [self continueToHome];
}

- (void) locationPermissionGranted {
    [MPush setLocationEnabled:YES];
    [LocationManager sharedInstance].delegate = nil;
    [self triggerAssetPermissionAndContinue];
}

- (void) locationPermissionError:(NSString *)errorMessage {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:errorMessage withModalType:ModalTypeError];
    [APPDELEGATE showCustomAlert:alert];

    [LocationManager sharedInstance].delegate = nil;
}

- (void) didDismissCustomAlert:(CustomAlertView *)alertView {
    [autoSyncSwitch setOn:NO];
    [self fadeOut:choiceTable duration:0.1];
    [self fadeOut:choiceTitleLabel duration:0.1];

    [self performSelector:@selector(moveToOpeningPage) withObject:nil afterDelay:0.2f];
}

- (void) triggerAssetPermissionAndContinue {
    
    ALAuthorizationStatus photoLibraryStatus = [ALAssetsLibrary authorizationStatus];
    if (photoLibraryStatus != ALAuthorizationStatusAuthorized) {
        if(photoLibraryStatus == ALAuthorizationStatusNotDetermined) {
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [self continueToHome];
            } failureBlock:^(NSError *error) {
//                if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                    [self showErrorAlertWithMessage:NSLocalizedString(@"AssetForAutoSyncError", @"")];
                    return;
//                }
//                [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
//                [self continueToHome];
            }];
        } else {
            [self showErrorAlertWithMessage:NSLocalizedString(@"AssetForAutoSyncError", @"")];
            return;
        }
    } else {
        [self continueToHome];
    }
    
    
    /*
     ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
     if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
     ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
     if (granted) { } else { }
     });
     }
     else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) { }
     else { }
     */
    
}

- (void) continueToHome {
    [CacheUtil writeCachedSettingSyncContacts:EnableOptionOn];
    [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOn];
    
    [[CurioSDK shared] sendEvent:@"SyncOpened" eventValue:@"true"];
    [MPush hitTag:@"SyncOpened" withValue:@"true"];
    
    if(selectedOption == ConnectionOptionWifi3G) {
        [[CurioSDK shared] sendEvent:@"FirstAutoSyncPref" eventValue:@"any"];
        [MPush hitTag:@"firstautosync_wifi3g"];
        [MPush hitEvent:@"firstautosync_wifi3g"];
    } else {
        [[CurioSDK shared] sendEvent:@"FirstAutoSyncPref" eventValue:@"wifi"];
        [MPush hitTag:@"firstautosync_wifi"];
        [MPush hitEvent:@"firstautosync_wifi"];
    }
    
    [CacheUtil writeCachedSettingSyncingConnectionType:selectedOption];
    [CacheUtil writeCachedSettingDataRoaming:NO];
    
    [AppUtil writeFirstVisitOverFlag];
    //    [APPDELEGATE triggerHome];
    
    [APPDELEGATE startOpeningPage];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"show-faq"]) {
            NSURL *url = [NSURL URLWithString:@"http://trcll.im/zbQxU"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void) showLocInfoPopup {
    if(autoSyncSwitch.isOn) {
        locInfoPopup = [[CustomInfoWithIconView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withIcon:@"icon_locationperm.png" withInfo:NSLocalizedString(@"LocInfoPopup", @"") withSubInfo:NSLocalizedString(@"LocSubinfoPopup", @"") isCloseable:YES];
        locInfoPopup.delegate = self;
        [self.view addSubview:locInfoPopup];
        [AppUtil writeLocInfoPopupShownFlag];
    } else {
        [self moveToOpeningPage];
    }
}

- (void) moveToOpeningPage {
    [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
    [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
    
    [[CurioSDK shared] sendEvent:@"SyncClosed" eventValue:@"true"];
    [MPush hitTag:@"SyncClosed" withValue:@"true"];
    [[CurioSDK shared] sendEvent:@"FirstAutoSyncPref" eventValue:@"closed"];
    
    [MPush hitTag:@"firstautosync_off"];
    [MPush hitEvent:@"firstautosync_off"];
    
    [CacheUtil writeCachedSettingSyncingConnectionType:selectedOption];
    [CacheUtil writeCachedSettingDataRoaming:NO];
    
    [AppUtil writeFirstVisitOverFlag];
    //    [APPDELEGATE triggerHome];
    [APPDELEGATE startOpeningPage];
}

- (void) customInfoWithIconViewDidDismiss {
    if(![CLLocationManager locationServicesEnabled]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"LocForAutoSyncError", @"")];
        return;
    } else {
        [LocationManager sharedInstance].delegate = self;
        [[LocationManager sharedInstance] startLocationManager];
    }
}

@end

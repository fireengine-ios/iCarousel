//
//  PostLoginSyncContactController.m
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginSyncContactController.h"
#import "Util.h"
#import "CustomLabel.h"
#import "PostLoginSyncPrefController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface PostLoginSyncContactController ()

@end

@implementation PostLoginSyncContactController

@synthesize onOff;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        UIImage *contactImg = [UIImage imageNamed:@"contacts_backup.png"];
        
        UIImageView *contactImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - contactImg.size.width)/2, 50, contactImg.size.width, contactImg.size.height)];
        contactImgView.image = contactImg;
        [self.view addSubview:contactImgView];
        
        NSString *descStr = NSLocalizedString(@"PostLoginContactPrefInfo", @"");
        UIFont *descFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:18];
        
        int descHeight = [Util calculateHeightForText:descStr forWidth:self.view.frame.size.width-40 forFont:descFont] + 5;
        
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, contactImgView.frame.origin.y + contactImgView.frame.size.height + 20, self.view.frame.size.width - 40, descHeight) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:descStr withAlignment:NSTextAlignmentCenter];
        descLabel.numberOfLines = 0;
        [self.view addSubview:descLabel];

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, descLabel.frame.origin.y + descLabel.frame.size.height + (IS_IPHONE_5 ? 30 : 10), self.view.frame.size.width, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"63beea"];
        [self.view addSubview:separator];
        
        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, separator.frame.origin.y + separator.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 230, 20) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"SyncContactsTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        onOff = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, separator.frame.origin.y + separator.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 40, 20)];
        [onOff setOn:YES];
        onOff.isAccessibilityElement = YES;
        onOff.accessibilityIdentifier = @"onOffSwitchPostLogin";
        [self.view addSubview:onOff];

        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [continueButton addTarget:self action:@selector(continueClicked) forControlEvents:UIControlEventTouchUpInside];
        continueButton.isAccessibilityElement = YES;
        continueButton.accessibilityIdentifier = @"continueButtonPostLogin";
        [self.view addSubview:continueButton];
        
    }
    return self;
}

- (void) continueClicked {
    if(onOff.isOn) {
        
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                } else {
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        }
        else {
        }
        
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionAuto];
    } else {
        [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
    }
    PostLoginSyncPrefController *syncPref = [[PostLoginSyncPrefController alloc] init];
    [self.navigationController pushViewController:syncPref animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

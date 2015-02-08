//
//  PostLoginSyncPhotoController.m
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PostLoginSyncPhotoController.h"
#import "Util.h"
#import "PostLoginSyncContactController.h"
#import "AppDelegate.h"

@interface PostLoginSyncPhotoController ()

@end

@implementation PostLoginSyncPhotoController

@synthesize onOff;
@synthesize assetsLibrary;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        
        UIImage *cameraImg = [UIImage imageNamed:@"camera_backup.png"];
        
        UIImageView *cameraImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - cameraImg.size.width)/2, 50, cameraImg.size.width, cameraImg.size.height)];
        cameraImgView.image = cameraImg;
        [self.view addSubview:cameraImgView];
        
        NSString *descStr = NSLocalizedString(@"PostLoginImgPrefInfo", @"");
        UIFont *descFont = [UIFont fontWithName:@"TurkcellSaturaBol" size:18];
        
        int descHeight = [Util calculateHeightForText:descStr forWidth:self.view.frame.size.width-40 forFont:descFont] + 5;
        
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, cameraImgView.frame.origin.y + cameraImgView.frame.size.height + 20, self.view.frame.size.width - 40, descHeight) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:descStr withAlignment:NSTextAlignmentCenter];
        descLabel.numberOfLines = 0;
        [self.view addSubview:descLabel];

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, descLabel.frame.origin.y + descLabel.frame.size.height + (IS_IPHONE_5 ? 30 : 10), self.view.frame.size.width, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"63beea"];
        [self.view addSubview:separator];

        CustomLabel *switchLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, separator.frame.origin.y + separator.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 230, 20) withFont:descFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:NSLocalizedString(@"SyncPhotoVideoTitle", @"") withAlignment:NSTextAlignmentLeft];
        switchLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:switchLabel];
        
        onOff = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, separator.frame.origin.y + separator.frame.size.height + (IS_IPHONE_5 ? 30 : 10), 40, 20)];
        [onOff setOn:NO];
        [self.view addSubview:onOff];

        SimpleButton *continueButton = [[SimpleButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width - 40, 50) withTitle:NSLocalizedString(@"Continue", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [continueButton addTarget:self action:@selector(continueClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:continueButton];
        
    }
    return self;
}

- (void) continueClicked {
    if(onOff.isOn) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group == nil) {
                [self postAssetPermission];
            }
        } failureBlock:^(NSError *error) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
            /*
            if (error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"", @"ALAssetsAccessError")];
            } else if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"", @"ALAssetsAccessError")];
            } else {
                [self showErrorAlertWithMessage:NSLocalizedString(@"", @"ALAssetsAccessError")];
            }
             */
        }];
    } else {
        [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionOff];
        PostLoginSyncContactController *contactPref = [[PostLoginSyncContactController alloc] init];
        [self.navigationController pushViewController:contactPref animated:YES];
    }
}

- (void) postAssetPermission {
    [CacheUtil writeCachedSettingSyncPhotosVideos:EnableOptionAuto];
    PostLoginSyncContactController *contactPref = [[PostLoginSyncContactController alloc] init];
    [self.navigationController pushViewController:contactPref animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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

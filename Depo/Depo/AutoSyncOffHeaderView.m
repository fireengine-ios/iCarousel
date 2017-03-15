//
//  AutoSyncOffHeaderView.m
//  Depo
//
//  Created by Mahir Tarlan on 10/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "AutoSyncOffHeaderView.h"
#import "CustomLabel.h"
#import "CustomButton.h"
#import "Util.h"

@implementation AutoSyncOffHeaderView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame withWifiFlag:(BOOL) wifiFlag {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"F6F6F6"];
        
        UIImage *cloudImg = [UIImage imageNamed:@"icon_bottom_sync_purple.png"];
        UIImage *settingsButtonImg = [UIImage imageNamed:@"buttonbg_224_yellow.png"];

        UIImageView *cloudImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (self.frame.size.height - cloudImg.size.height)/2, cloudImg.size.width, cloudImg.size.height)];
        cloudImgView.image = cloudImg;
        [self addSubview:cloudImgView];
        
        float textXIndex = cloudImg.size.width + 20;
        
        CustomLabel *topLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(textXIndex, self.frame.size.height/2 - 20, self.frame.size.width - textXIndex - settingsButtonImg.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:13] withColor:[Util UIColorForHexColor:@"555555"] withText:wifiFlag ? NSLocalizedString(@"AutoSyncOffInfoTopWifi", @"") : NSLocalizedString(@"AutoSyncOffInfoTop", @"") withAlignment:NSTextAlignmentLeft];
        [self addSubview:topLabel];

        CustomLabel *bottomLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(textXIndex, self.frame.size.height/2, self.frame.size.width - textXIndex - settingsButtonImg.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"AutoSyncOffInfoBottom", @"") withAlignment:NSTextAlignmentLeft];
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:bottomLabel];
        
        CustomButton *settingsButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - settingsButtonImg.size.width - 40, (self.frame.size.height - settingsButtonImg.size.height)/2, settingsButtonImg.size.width, settingsButtonImg.size.height) withImageName:@"buttonbg_224_yellow.png"];
        [settingsButton addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingsButton];

        UIImageView *innerIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, (settingsButton.frame.size.height - 10)/2, 10, 10)];
        innerIconImgView.image = [UIImage imageNamed:@"icon_button_settings.png"];
        innerIconImgView.contentMode = UIViewContentModeScaleAspectFill;
        [settingsButton addSubview:innerIconImgView];

        CustomLabel *innerSettingsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(innerIconImgView.frame.origin.x + innerIconImgView.frame.size.width + 3, (settingsButton.frame.size.height - 12)/2, settingsButton.frame.size.width - (innerIconImgView.frame.origin.x + innerIconImgView.frame.size.width + 12), 12) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:11] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"SettingsTitle", @"") withAlignment:NSTextAlignmentLeft];
        innerSettingsLabel.adjustsFontSizeToFitWidth = YES;
        [settingsButton addSubview:innerSettingsLabel];

        UIImage *closeButtonImg = [UIImage imageNamed:@"close_icon.png"];
        
        CustomButton *closeButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - closeButtonImg.size.width - 10, (self.frame.size.height - closeButtonImg.size.height)/2, closeButtonImg.size.width, closeButtonImg.size.height) withImageName:@"close_icon.png"];
        [closeButton addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

- (void) settingsClicked {
    [delegate autoSyncOffHeaderViewSettingsClicked];
}

- (void) closeClicked {
    [delegate autoSyncOffHeaderViewCloseClicked];
}

@end

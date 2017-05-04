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

@interface AutoSyncOffHeaderView() {
    CustomLabel *bottomLabel;
}
@end

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

        bottomLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(textXIndex, self.frame.size.height/2, self.frame.size.width - textXIndex - settingsButtonImg.size.width - 60, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"AutoSyncOffInfoBottom", @"") withAlignment:NSTextAlignmentLeft];
        bottomLabel.adjustsFontSizeToFitWidth = NO;
        [self addSubview:bottomLabel];
        
//        CustomButton *settingsButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - settingsButtonImg.size.width - 40, (self.frame.size.height - settingsButtonImg.size.height)/2, settingsButtonImg.size.width + 10, settingsButtonImg.size.height + 10) withImageName:@"buttonbg_224_yellow.png"];
//        [settingsButton addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
//        settingsButton.backgroundColor = [UIColor redColor];
//        [self addSubview:settingsButton];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsClicked)];
        singleTap.numberOfTapsRequired = 1;
        
        float settingButtonIVWidth = settingsButtonImg.size.width + 22 + 2;
        float settingButtonIVHeight = settingsButtonImg.size.height + 13;
        
        UIImageView *settingsButtonIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - settingButtonIVWidth - 40, (self.frame.size.height - settingButtonIVHeight)/2, settingButtonIVWidth, settingButtonIVHeight)];
//        settingsButtonIV.image = settingsButtonImg;
        settingsButtonIV.backgroundColor = [Util UIColorForHexColor:@"FFE000"];
        settingsButtonIV.layer.cornerRadius = 18;
        settingsButtonIV.layer.masksToBounds = YES;
        [settingsButtonIV setUserInteractionEnabled:YES];
        [settingsButtonIV addGestureRecognizer:singleTap];
        settingsButtonIV.isAccessibilityElement = YES;
        settingsButtonIV.accessibilityIdentifier = @"AutoSyncSettingsButton";
        [self addSubview:settingsButtonIV];

        UIImageView *innerIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, (settingsButtonIV.frame.size.height - 10)/2 -0.5, 10, 10)];
        innerIconImgView.image = [UIImage imageNamed:@"icon_button_settings.png"];
        innerIconImgView.contentMode = UIViewContentModeScaleAspectFill;
        [settingsButtonIV addSubview:innerIconImgView];

        CustomLabel *innerSettingsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(innerIconImgView.frame.origin.x + innerIconImgView.frame.size.width + 3, (settingsButtonIV.frame.size.height - 12)/2, settingsButtonIV.frame.size.width - (innerIconImgView.frame.origin.x + innerIconImgView.frame.size.width + 12), 12) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[UIColor blackColor] withText:NSLocalizedString(@"SettingsTitle", @"") withAlignment:NSTextAlignmentLeft];
        innerSettingsLabel.adjustsFontSizeToFitWidth = NO;
        [settingsButtonIV addSubview:innerSettingsLabel];

        UIImage *closeButtonImg = [UIImage imageNamed:@"close_icon.png"];
        
        CustomButton *closeButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - closeButtonImg.size.width - 10, (self.frame.size.height - closeButtonImg.size.height)/2, closeButtonImg.size.width, closeButtonImg.size.height) withImageName:@"close_icon.png"];
        [closeButton addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
        closeButton.isAccessibilityElement = YES;
        closeButton.accessibilityIdentifier = @"SyncHeaderCloseButton";
        [self addSubview:closeButton];
    }
    return self;
}

- (void) updateBottomLabelWithCount:(int) count {
    bottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"AutoSyncOffInfoBottomWithCount", @""), count];
}

- (void) settingsClicked {
    [delegate autoSyncOffHeaderViewSettingsClicked];
}

- (void) closeClicked {
    [delegate autoSyncOffHeaderViewCloseClicked];
}

@end

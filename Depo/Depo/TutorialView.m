//
//  TutorialView.m
//  Depo
//
//  Created by Mahir Tarlan on 17/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "TutorialView.h"
#import "Util.h"
#import "AppUtil.h"

@interface TutorialView() {
    NSString *keyRef;
}
@end

@implementation TutorialView

@synthesize checkButton;

- (id) initWithFrame:(CGRect)frame withBgImageName:(NSString *) imgName withTitle:(NSString *) titleVal withKey:(NSString *) keyVal {
    if(self = [super initWithFrame:frame]) {
        keyRef = keyVal;
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgImgView.image = [UIImage imageNamed:imgName];
        bgImgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:bgImgView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerDismiss)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [self addGestureRecognizer:tapGestureRecognizer];

        NSString *checkMessage = NSLocalizedString(@"DontShowAgainMessage", @"");
        UIFont *checkFont = [UIFont fontWithName:@"TurkcellSaturaMed" size:14];
        
        float messageWidth = [Util calculateWidthForText:checkMessage forHeight:20 forFont:checkFont] + 10;
        
        CustomLabel *checkLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - messageWidth - 10, self.frame.size.height - 30, messageWidth, 20) withFont:checkFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:checkMessage];
        [self addSubview:checkLabel];

        checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(checkLabel.frame.origin.x - 30, self.frame.size.height - 30, 21, 20) isInitiallyChecked:NO];
        [self addSubview:checkButton];

    }
    return self;
}

- (void) triggerDismiss {
    if(checkButton.isChecked) {
        [AppUtil writeDoNotShowAgainFlagForKey:keyRef];
    }
    [self removeFromSuperview];
}

@end

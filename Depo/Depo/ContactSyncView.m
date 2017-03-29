//
//  ContactSyncView.m
//  Depo
//
//  Created by Turan Yilmaz on 26/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ContactSyncView.h"
#import "AppConstants.h"
#import "Util.h"

@implementation ContactSyncView

- (id) initWithFrame:(CGRect) frame {
    if(self = [super initWithFrame:frame]) {
        
        float buttonHeight = IS_IPAD ? 54 : IS_IPHONE_6P_OR_HIGHER ? 44 : 36;
        float buttonWidth = IS_IPAD ? 250 : IS_IPHONE_6P_OR_HIGHER ? 150 : 120;
        float circleProgressWidth = IS_IPAD ? 350 : frame.size.width - 100;
     
        UIImageView *circleProgressIV = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-circleProgressWidth)/2, IS_IPAD ? 30 : 0, circleProgressWidth, circleProgressWidth)];
        circleProgressIV.image = [UIImage imageNamed:@"contact_progress.png"];
        [self addSubview:circleProgressIV];
        
        
        UIImageView *contactsIconIV = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-100)/2, circleProgressIV.frame.origin.y + (circleProgressIV.frame.size.height - 100)/2, 100, 100)];
        contactsIconIV.image = [UIImage imageNamed:@"new_contacts_icon.png"];
        contactsIconIV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:contactsIconIV];
        
        self.backupButton = [[SimpleButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - buttonWidth - 5,
                                                                           circleProgressIV.frame.origin.y + circleProgressIV.frame.size.height + (IS_IPAD ? 70 : 40),
                                                                      buttonWidth,
                                                                      buttonHeight)
                                                 withTitle:[NSLocalizedString(@"ContactBackupButtonTitle", @"") uppercaseString]
                                            withTitleColor:[Util UIColorForHexColor:@"363e4f"]
                                                  withTitleFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:IS_IPHONE_6P_OR_HIGHER ? 16 : 14]
                                           withBorderColor:[Util UIColorForHexColor:@"ffe000"]
                                               withBgColor:[Util UIColorForHexColor:@"ffe000"]
                                          withCornerRadius:5];
        [self.backupButton addTarget:self action:@selector(backupClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backupButton];
        
        
        self.restoreButton = [[SimpleButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 + 5,
                                                                       circleProgressIV.frame.origin.y + circleProgressIV.frame.size.height + (IS_IPAD ? 70 : 40),
                                                                       buttonWidth,
                                                                       buttonHeight)
                                                  withTitle:[NSLocalizedString(@"ContactRestoreButtonTitle", @"") uppercaseString]
                                             withTitleColor:[Util UIColorForHexColor:@"363e4f"]
                                              withTitleFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:IS_IPHONE_6P_OR_HIGHER ? 16 : 14]
                                            withBorderColor:[Util UIColorForHexColor:@"ffe000"]
                                                withBgColor:[Util UIColorForHexColor:@"ffe000"]
                                           withCornerRadius:5];
        [self.restoreButton addTarget:self action:@selector(restoreClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.restoreButton];
        
        
    }
    return self;
}

- (void) backupClicked {
    [self.delegate backupClicked];
}

- (void) restoreClicked {
    [self.delegate restoreClicked];
}

@end

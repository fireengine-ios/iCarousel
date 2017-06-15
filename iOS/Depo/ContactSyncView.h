//
//  ContactSyncView.h
//  Depo
//
//  Created by Turan Yilmaz on 26/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleButton.h"

@protocol ContactSyncViewDelegate <NSObject>

- (void) backupClicked;
- (void) restoreClicked;

@end

@interface ContactSyncView : UIView

- (id) initWithFrame:(CGRect) frame;

@property (nonatomic, strong) id<ContactSyncViewDelegate> delegate;
@property (nonatomic,strong) SimpleButton *backupButton;
@property (nonatomic,strong) SimpleButton *restoreButton;

@end

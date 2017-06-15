//
//  ContactSyncResultView.h
//  Depo
//
//  Created by Turan Yilmaz on 28/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@protocol ContactSyncResultViewDelegate <NSObject>

- (void) continueButtonClicked;

@end

@interface ContactSyncResultView : UIView

- (id) initWithFrame:(CGRect)frame;

@property (nonatomic, strong) id<ContactSyncResultViewDelegate> delegate;
@property (nonatomic,strong) CustomLabel *totalCountLabel;
@property (nonatomic,strong) CustomLabel *label;

@end

//
//  ConfirmRemoveModalController.h
//  Depo
//
//  Created by Seyma Tanoglu on 09/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SimpleButton.h"
#import "CheckButton.h"

@protocol ConfirmRemoveDelegate <NSObject>
- (void) confirmRemoveDidCancel;
- (void) confirmRemoveDidConfirm;
@end

@interface ConfirmRemoveModalController : MyModalController

@property (nonatomic, strong) id<ConfirmRemoveDelegate> delegate;
@property (nonatomic, strong) SimpleButton *cancelButton;
@property (nonatomic, strong) SimpleButton *confirmButton;
@property (nonatomic, strong) CheckButton *checkButton;

@end


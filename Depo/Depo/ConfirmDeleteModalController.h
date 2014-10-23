//
//  ConfirmDeleteModalController.h
//  Depo
//
//  Created by Mahir on 10/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SimpleButton.h"
#import "CheckButton.h"

@protocol ConfirmDeleteDelegate <NSObject>
- (void) confirmDeleteDidCancel;
- (void) confirmDeleteDidConfirm;
@end

@interface ConfirmDeleteModalController : MyModalController

@property (nonatomic, strong) id<ConfirmDeleteDelegate> delegate;
@property (nonatomic, strong) SimpleButton *cancelButton;
@property (nonatomic, strong) SimpleButton *confirmButton;
@property (nonatomic, strong) CheckButton *checkButton;

@end

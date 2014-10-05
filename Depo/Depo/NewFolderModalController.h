//
//  NewFolderModalController.h
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralTextField.h"
#import "MyModalController.h"

@protocol NewFolderDelegate <NSObject>
- (void) newFolderModalDidTriggerNewFolderWithName:(NSString *) folderName;
@end

@interface NewFolderModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<NewFolderDelegate> delegate;
@property (nonatomic, strong) GeneralTextField *nameField;

@end

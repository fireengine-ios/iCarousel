//
//  FolderDetailModalController.h
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "MetaFile.h"
#import "GeneralTextField.h"

@protocol FolderDetailDelegate <NSObject>
- (void) folderDetailShouldRename:(NSString *) newNameVal;
@end

@interface FolderDetailModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<FolderDetailDelegate> delegate;
@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) GeneralTextField *nameField;

- (id) initWithFolder:(MetaFile *) _folder;

@end

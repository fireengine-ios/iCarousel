//
//  FileDetailModalController.h
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "MetaFile.h"
#import "GeneralTextField.h"

@protocol FileDetailDelegate <NSObject>
- (void) fileDetailShouldRename:(NSString *) newNameVal;
@end

@interface FileDetailModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<FileDetailDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) GeneralTextField *nameField;
@property (nonatomic, strong) GeneralTextField *titleField;
@property (nonatomic, strong) GeneralTextField *artistField;
@property (nonatomic, strong) GeneralTextField *albumField;

- (id) initWithFile:(MetaFile *) _file;

@end

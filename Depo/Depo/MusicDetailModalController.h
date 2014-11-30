//
//  MusicDetailModalController.h
//  Depo
//
//  Created by Mahir on 30.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "MetaFile.h"
#import "GeneralTextField.h"

@protocol MusicDetailDelegate <NSObject>
- (void) musicDetailShouldRename:(NSString *) newNameVal;
@end

@interface MusicDetailModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<MusicDetailDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) GeneralTextField *nameField;

- (id) initWithFile:(MetaFile *) _file;


@end

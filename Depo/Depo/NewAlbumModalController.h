//
//  NewAlbumModalController.h
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "GeneralTextField.h"

@protocol NewAlbumDelegate <NSObject>
- (void) newAlbumModalDidTriggerNewAlbumWithName:(NSString *) albumName;
@end


@interface NewAlbumModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<NewAlbumDelegate> delegate;
@property (nonatomic, strong) GeneralTextField *nameField;

@end

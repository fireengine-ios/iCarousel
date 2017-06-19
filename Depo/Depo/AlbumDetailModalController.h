//
//  AlbumDetailModalController.h
//  Depo
//
//  Created by Mahir on 14.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "PhotoAlbum.h"
#import "GeneralTextField.h"

@protocol AlbumDetailDelegate <NSObject>
- (void) albumDetailShouldRenameWithName:(NSString *) newName;
@end

@interface AlbumDetailModalController : MyModalController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<AlbumDetailDelegate> delegate;
@property (nonatomic, strong) PhotoAlbum *album;
@property (nonatomic, strong) GeneralTextField *nameField;
@property (nonatomic, strong) CustomButton *doneButton;

- (id) initWithAlbum:(PhotoAlbum *) _album;

@end

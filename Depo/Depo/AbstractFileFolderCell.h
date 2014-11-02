//
//  AbstractFileFolderCell.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppUtil.h"
#import "CustomButton.h"
#import "CheckButton.h"

@protocol AbstractFileFolderDelegate <NSObject>
- (void) fileFolderCellShouldFavForFile:(MetaFile *) fileSelected;
- (void) fileFolderCellShouldUnfavForFile:(MetaFile *) fileSelected;
- (void) fileFolderCellShouldDeleteForFile:(MetaFile *) fileSelected;
- (void) fileFolderCellShouldShareForFile:(MetaFile *) fileSelected;
- (void) fileFolderCellShouldMoveForFile:(MetaFile *) fileSelected;
- (void) fileFolderCellDidSelectFile:(MetaFile *) fileSelected;
- (void) fileFolderCellDidUnselectFile:(MetaFile *) fileSelected;
@end

@interface AbstractFileFolderCell : UITableViewCell

@property (nonatomic, strong) id<AbstractFileFolderDelegate> delegate;
@property (nonatomic, strong) MetaFile *fileFolder;
@property (nonatomic, strong) UIView *swipeMenu;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *favButton;
@property (nonatomic, strong) CustomButton *unfavButton;
@property (nonatomic, strong) CustomButton *moveButton;
@property (nonatomic, strong) CustomButton *deleteButton;
@property (nonatomic, strong) CheckButton *checkButton;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic) BOOL menuActive;
@property (nonatomic) BOOL isSelectible;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL) _selectible;
- (UIFont *) readNameFont;
- (UIFont *) readDetailFont;
- (UIColor *) readNameColor;
- (UIColor *) readDetailColor;
- (UIColor *) readPassiveSeparatorColor;
- (void) initializeSwipeMenu;
- (void) manuallyCheckButton;
- (void) triggerFileSelectDeselect;
- (void) addMaskLayer;

@end

//
//  AbstractFileFolderCell.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AbstractFileFolderCell.h"

@implementation AbstractFileFolderCell

@synthesize delegate;
@synthesize fileFolder;
@synthesize swipeMenu;
@synthesize shareButton;
@synthesize favButton;
@synthesize unfavButton;
@synthesize moveButton;
@synthesize deleteButton;
@synthesize imgView;
@synthesize menuActive;
@synthesize isSelectible;
@synthesize isSwipeable;
@synthesize checkButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL) _selectible {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible isSwipeable:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL) _selectible isSwipeable:(BOOL) _swipeable {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fileFolder = _fileFolder;
        self.isSelectible = _selectible;
        self.isSwipeable = _swipeable;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(swipeLeft)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:recognizerLeft];
        
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(swipeRight)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:recognizerRight];
    }
    return self;
}

- (void) initializeSwipeMenu {
    swipeMenu = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width - 30, 67)];
    swipeMenu.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
    [self addSubview:swipeMenu];

    int buttonPlaygroundX = swipeMenu.frame.size.width / 4;

    shareButton = [[CustomButton alloc] initWithFrame:CGRectMake((buttonPlaygroundX - 16)/2, 22, 16, 22) withImageName:@"white_share_icon.png"];
    [shareButton addTarget:self action:@selector(triggerShare) forControlEvents:UIControlEventTouchUpInside];
    [swipeMenu addSubview:shareButton];

    favButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX + (buttonPlaygroundX - 20)/2, 23, 20, 20) withImageName:@"fav_icon.png"];
    [favButton addTarget:self action:@selector(triggerFav) forControlEvents:UIControlEventTouchUpInside];
    [swipeMenu addSubview:favButton];
    
    unfavButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX + (buttonPlaygroundX - 20)/2, 23, 20, 20) withImageName:@"yellow_fav_icon.png"];
    [unfavButton addTarget:self action:@selector(triggerUnfav) forControlEvents:UIControlEventTouchUpInside];
    [swipeMenu addSubview:unfavButton];
    
    if(self.fileFolder.detail.favoriteFlag) {
        favButton.hidden = YES;
        unfavButton.hidden = NO;
    } else {
        favButton.hidden = NO;
        unfavButton.hidden = YES;
    }

    moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX*2 + (buttonPlaygroundX - 18)/2, 23, 18, 20) withImageName:@"white_move_icon.png"];
    [moveButton addTarget:self action:@selector(triggerMove) forControlEvents:UIControlEventTouchUpInside];
    [swipeMenu addSubview:moveButton];

    deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX*3 + (buttonPlaygroundX - 20)/2, 23, 20, 21) withImageName:@"white_delete_icon.png"];
    [deleteButton addTarget:self action:@selector(triggerDelete) forControlEvents:UIControlEventTouchUpInside];
    [swipeMenu addSubview:deleteButton];
}

- (void) swipeLeft {
    if(isSelectible || !isSwipeable)
        return;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         swipeMenu.frame = CGRectMake(30, 0, self.frame.size.width - 30, 67);
                     } completion:^(BOOL finished) {
                         menuActive = YES;
                         imgView.hidden = YES;
                     }];
}

- (void) swipeRight {
    if(isSelectible || !isSwipeable)
        return;

    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         swipeMenu.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width - 30, 67);
                     } completion:^(BOOL finished) {
                         menuActive = NO;
                         imgView.hidden = NO;
                     }];
}

- (UIFont *) readNameFont {
    return [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
}

- (UIFont *) readDetailFont {
    return [UIFont fontWithName:@"TurkcellSaturaMed" size:16];
}

- (UIColor *) readNameColor {
    return [Util UIColorForHexColor:@"363E4F"];
}

- (UIColor *) readDetailColor {
    return [Util UIColorForHexColor:@"707a8f"];
}

- (UIColor *) readPassiveSeparatorColor {
    return [Util UIColorForHexColor:@"E1E1E1"];
}

- (void) triggerFav {
    unfavButton.hidden = NO;
    [UIView transitionFromView:favButton toView:unfavButton duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
    [delegate fileFolderCellShouldFavForFile:self.fileFolder];
}

- (void) triggerUnfav {
    favButton.hidden = NO;
    [UIView transitionFromView:unfavButton toView:favButton duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
    [delegate fileFolderCellShouldUnfavForFile:self.fileFolder];
}

- (void) triggerShare {
    [delegate fileFolderCellShouldShareForFile:self.fileFolder];
}

- (void) triggerDelete {
    [delegate fileFolderCellShouldDeleteForFile:self.fileFolder];
}

- (void) triggerMove {
    [delegate fileFolderCellShouldMoveForFile:self.fileFolder];
}

- (void) triggerFileSelectDeselect {
    [self.checkButton toggle];
    if(self.checkButton.isChecked) {
        [delegate fileFolderCellDidSelectFile:self.fileFolder];
    } else {
        [delegate fileFolderCellDidUnselectFile:self.fileFolder];
    }
}

- (void) manuallyCheckButton {
    [self.checkButton manuallyCheck];
}

- (void) layoutSubviews {
}

- (void) addMaskLayer {
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 67)];
    maskView.backgroundColor = [UIColor whiteColor];
    maskView.alpha = 0.6f;
    [self addSubview:maskView];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  AbstractFileFolderCell.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AbstractFileFolderCell.h"

@implementation AbstractFileFolderCell

@synthesize fileFolder;
@synthesize swipeMenu;
@synthesize shareButton;
@synthesize favButton;
@synthesize moveButton;
@synthesize deleteButton;
@synthesize menuActive;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fileFolder = _fileFolder;
        
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
    [swipeMenu addSubview:shareButton];

    favButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX + (buttonPlaygroundX - 20)/2, 23, 20, 20) withImageName:@"fav_icon.png"];
    [swipeMenu addSubview:favButton];

    moveButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX*2 + (buttonPlaygroundX - 18)/2, 23, 18, 20) withImageName:@"white_move_icon.png"];
    [swipeMenu addSubview:moveButton];

    deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(buttonPlaygroundX*3 + (buttonPlaygroundX - 20)/2, 23, 20, 21) withImageName:@"white_delete_icon.png"];
    [swipeMenu addSubview:deleteButton];
}

- (void) swipeLeft {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         swipeMenu.frame = CGRectMake(30, 0, self.frame.size.width - 30, 67);
                     } completion:^(BOOL finished) {
                         menuActive = YES;
                     }];
}

- (void) swipeRight {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         swipeMenu.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width - 30, 67);
                     } completion:^(BOOL finished) {
                         menuActive = NO;
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

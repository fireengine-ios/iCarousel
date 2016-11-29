//
//  AlbumCell.m
//  Depo
//
//  Created by Salih GUC on 28/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "AlbumCell.h"

@interface AlbumCell () {
    CustomLabel *nameLabel;
    UIView *progressSeparator;
}
@end

@implementation AlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO autoActionFlag:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeAlbumPhoto]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftIndex + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(leftIndex + 55, (self.frame.size.height - 22) / 2, self.frame.size.width - 80, 22);        
        UIFont *nameFont = [self readNameFont];
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        [self initializeSwipeMenu];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder highlightedText:(NSString *)highlightedText {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:NO];
    if (self) {
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeAlbumPhoto]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(70, (self.frame.size.height - 22) / 2, self.frame.size.width - 80, 22);
        UIFont *nameFont = [self readNameFont];
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        NSRange highlightingRange = [self.fileFolder.visibleName rangeOfString:highlightedText options:NSCaseInsensitiveSearch];
        if ((int)highlightingRange.location >= 0) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: nameLabel.attributedText];
            [text addAttribute:NSForegroundColorAttributeName value:[Util UIColorForHexColor:@"3FB0E8"] range:highlightingRange];
            [nameLabel setAttributedText: text];
        }
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        [self initializeSwipeMenu];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:NO];
    if (self) {
        self.isSwipeable = NO;
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeAlbumPhoto]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(70, (self.frame.size.height - 22) / 2, self.frame.size.width - 120, 22);
        UIFont *nameFont = [self readNameFont];
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        self.independentFavButton = [[CustomButton alloc] initWithFrame:CGRectMake(270, 14, 40, 40) withImageName:@"nav_favourite_inactive_icon"];
        [self.independentFavButton addTarget:self action:@selector(triggerFav) forControlEvents:UIControlEventTouchUpInside];
        self.independentFavButton.hidden = YES;
        [self addSubview:self.independentFavButton];
        
        self.independentUnfavButton = [[CustomButton alloc] initWithFrame:CGRectMake(270, 14, 40, 40) withImageName:@"nav_favourite_active_icon"];
        [self.independentUnfavButton addTarget:self action:@selector(triggerUnfav) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.independentUnfavButton];
    }
    return self;
}

- (void) layoutSubviews {
    int leftIndex = self.isSelectible ? 50 : 15;
    if(self.checkButton) {
        self.checkButton.frame = CGRectMake(15, (self.frame.size.height - 20)/2, 21, 20);
    }
    
    float imgWidth = IS_IPAD ? self.imgView.image.size.width*3/2 : self.imgView.image.size.width;
    float imgHeight = IS_IPAD ? self.imgView.image.size.height*3/2 : self.imgView.image.size.height;
    float imgMaxWidth = IS_IPAD ? 70 : 40;
    float totalLeftIndex = leftIndex + imgMaxWidth + 15;
    
    if(self.imgView) {
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeAlbumPhoto]];
        self.imgView.frame = CGRectMake(leftIndex + (imgMaxWidth - imgWidth)/2, (self.frame.size.height - imgHeight)/2, imgWidth, imgHeight);
        self.imgView.image = iconImg;
    }
    CGRect nameFieldRect = CGRectMake(totalLeftIndex, (self.frame.size.height - 22) / 2, self.frame.size.width - totalLeftIndex, 22);
    if(nameLabel) {
        nameLabel.frame = nameFieldRect;
    }
    if(progressSeparator) {
        progressSeparator.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    }
    if(self.independentFavButton) {
        self.independentFavButton.frame = CGRectMake(self.frame.size.width-50, (self.frame.size.height - 40)/2, 40, 40);
    }
    if(self.independentUnfavButton) {
        self.independentUnfavButton.frame = CGRectMake(self.frame.size.width-50, (self.frame.size.height - 40)/2, 40, 40);
    }
    [super layoutSubviews];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

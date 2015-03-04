//
//  MusicCell.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicCell.h"
#import "UIImageView+AFNetworking.h"

@implementation MusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;

        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeMusic]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftIndex + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        if(self.fileFolder.detail && self.fileFolder.detail.thumbMediumUrl && [self.fileFolder.detail.thumbMediumUrl length] > 0) {
            self.imgView.frame = CGRectMake(leftIndex + 2, 16, 35, 35);
            [self.imgView setImageWithURL:[NSURL URLWithString:self.fileFolder.detail.thumbMediumUrl]];
        }
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(leftIndex + 55, 13, self.frame.size.width - 80, 22);
        CGRect detailFieldRect = CGRectMake(leftIndex + 55, 35, self.frame.size.width - 80, 20);
        
        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
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
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeMusic]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        if(self.fileFolder.detail && self.fileFolder.detail.thumbMediumUrl && [self.fileFolder.detail.thumbMediumUrl length] > 0) {
            self.imgView.frame = CGRectMake(17, 16, 35, 35);
            [self.imgView setImageWithURL:[NSURL URLWithString:self.fileFolder.detail.thumbMediumUrl]];
        }
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(70, 13, self.frame.size.width - 80, 22);
        CGRect detailFieldRect = CGRectMake(70, 35, self.frame.size.width - 80, 20);
        
        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        NSRange highlightingRange = [self.fileFolder.visibleName rangeOfString:highlightedText options:NSCaseInsensitiveSearch];
        if ((int)highlightingRange.location >= 0) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: nameLabel.attributedText];
            [text addAttribute:NSForegroundColorAttributeName value:[Util UIColorForHexColor:@"3FB0E8"] range:highlightingRange];
            [nameLabel setAttributedText: text];
        }
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
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
        self.fileFolder = _fileFolder;
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeMusic]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        self.imgView.image = iconImg;
        if(self.fileFolder.detail && self.fileFolder.detail.thumbMediumUrl && [self.fileFolder.detail.thumbMediumUrl length] > 0) {
            self.imgView.frame = CGRectMake(17, 16, 35, 35);
            [self.imgView setImageWithURL:[NSURL URLWithString:self.fileFolder.detail.thumbMediumUrl]];
        }
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(70, 13, self.frame.size.width - 120, 22);
        CGRect detailFieldRect = CGRectMake(70, 35, self.frame.size.width - 120, 20);
        
        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        self.favButton = [[CustomButton alloc] initWithFrame:CGRectMake(270, 14, 40, 40) withImageName:@"nav_favourite_inactive_icon"];
        [self.favButton addTarget:self action:@selector(triggerFav) forControlEvents:UIControlEventTouchUpInside];
        self.favButton.hidden = YES;
        [self addSubview:self.favButton];
        
        self.unfavButton = [[CustomButton alloc] initWithFrame:CGRectMake(270, 14, 40, 40) withImageName:@"nav_favourite_active_icon"];
        [self.unfavButton addTarget:self action:@selector(triggerUnfav) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.unfavButton];
    }
    return self;
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

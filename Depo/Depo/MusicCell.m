//
//  MusicCell.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicCell.h"
#import "UIImageView+AFNetworking.h"

@interface MusicCell () {
    CustomLabel *nameLabel;
    CustomLabel *detailLabel;
    UIView *progressSeparator;
}
@end

@implementation MusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO autoActionFlag:NO];
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
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
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
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        NSRange highlightingRange = [self.fileFolder.visibleName rangeOfString:highlightedText options:NSCaseInsensitiveSearch];
        if ((int)highlightingRange.location >= 0) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: nameLabel.attributedText];
            [text addAttribute:NSForegroundColorAttributeName value:[Util UIColorForHexColor:@"3FB0E8"] range:highlightingRange];
            [nameLabel setAttributedText: text];
        }
        
        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
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
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:self.fileFolder.visibleName];
        [self addSubview:nameLabel];
        
        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:[Util transformedSizeValue:self.fileFolder.bytes]];
        [self addSubview:detailLabel];
        
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
//    NSLog(@"At layoutSubviews: %@", NSStringFromCGRect(self.frame));
    int leftIndex = self.isSelectible ? 50 : 15;
    if(self.checkButton) {
        self.checkButton.frame = CGRectMake(15, (self.frame.size.height - 20)/2, 21, 20);
    }

    float imgWidth = self.frame.size.height - 32;
    float maxWidth = IS_IPAD ? 70 : 40;
    float totalLeftIndex = leftIndex + maxWidth + 15;

    if(self.imgView) {
        self.imgView.frame = CGRectMake(leftIndex + (maxWidth - imgWidth)/2, (self.frame.size.height - imgWidth)/2, imgWidth, imgWidth);
    }
    CGRect nameFieldRect = CGRectMake(totalLeftIndex, self.frame.size.height/2 - 22, self.frame.size.width - totalLeftIndex, 22);
    CGRect detailFieldRect = CGRectMake(totalLeftIndex, self.frame.size.height/2, self.frame.size.width - totalLeftIndex, 20);
    if(nameLabel) {
        nameLabel.frame = nameFieldRect;
    }
    if(detailLabel) {
        detailLabel.frame = detailFieldRect;
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

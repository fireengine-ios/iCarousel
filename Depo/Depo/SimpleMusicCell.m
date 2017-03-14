//
//  SimpleMusicCell.m
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SimpleMusicCell.h"
#import "UIImageView+WebCache.h"

@interface SimpleMusicCell () {
    CustomLabel *nameLabel;
    CustomLabel *detailLabel;
    UIView *progressSeparator;
}
@end

@implementation SimpleMusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible isSwipeable:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible isSwipeable:(BOOL)_swipeable {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible isSwipeable:_swipeable];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO autoActionFlag:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil iconNameByContentType:ContentTypeMusic]];
        
        self.imgView  = [[UIImageView alloc] initWithFrame:CGRectMake(leftIndex + (40 - iconImg.size.width)/2, (68 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:_fileFolder.detail.thumbMediumUrl]
                        placeholderImage:iconImg];
        
//        self.imgView.image = iconImg;
        [self addSubview:self.imgView];
        
        CGRect nameFieldRect = CGRectMake(self.imgView.frame.origin.x + self.imgView.frame.size.width + 15,
                                          13,
                                          self.frame.size.width - 60 - self.imgView.frame.size.width,
                                          22);
        CGRect detailFieldRect = CGRectMake(self.imgView.frame.origin.x + self.imgView.frame.size.width + 15,
                                            35,
                                            self.frame.size.width - 60 - self.imgView.frame.size.width,
                                            20);
        
        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];
        
        NSString *nameVal = self.fileFolder.visibleName;
        if(self.fileFolder.detail && self.fileFolder.detail.songTitle) {
            nameVal = self.fileFolder.detail.songTitle;
        }
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:nameVal];
        [self addSubview:nameLabel];
        
        NSString *detailVal = @"";
        if(self.fileFolder.detail && self.fileFolder.detail.artist) {
            detailVal = self.fileFolder.detail.artist;
        }
        if(self.fileFolder.detail && self.fileFolder.detail.album) {
            detailVal = [NSString stringWithFormat:@"%@ - %@", detailVal, self.fileFolder.detail.album];
        }
        
        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:detailVal];
        [self addSubview:detailLabel];
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        [self initializeSwipeMenu];
    }
    return self;
}

- (void) layoutSubviews {
//    int leftIndex = self.isSelectible ? 50 : 15;
    if(self.checkButton) {
        self.checkButton.frame = CGRectMake(15, (self.frame.size.height - 20)/2, 21, 20);
    }
    CGRect nameFieldRect = CGRectMake(self.imgView.frame.origin.x + self.imgView.frame.size.width + 15,
                                      self.frame.size.height/2 - 22,
                                      self.frame.size.width - 60 - self.imgView.frame.size.width,
                                      22);
    CGRect detailFieldRect = CGRectMake(self.imgView.frame.origin.x + self.imgView.frame.size.width + 15,
                                        self.frame.size.height/2,
                                        self.frame.size.width - 60 - self.imgView.frame.size.width,
                                        20);
    if(nameLabel) {
        nameLabel.frame = nameFieldRect;
    }
    if(detailLabel) {
        detailLabel.frame = detailFieldRect;
    }
    if(progressSeparator) {
        progressSeparator.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    }
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

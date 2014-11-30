//
//  SimpleMusicCell.m
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SimpleMusicCell.h"

@implementation SimpleMusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;
        
        CGRect nameFieldRect = CGRectMake(leftIndex + 15, 13, self.frame.size.width - 30, 22);
        CGRect detailFieldRect = CGRectMake(leftIndex + 15, 35, self.frame.size.width - 30, 20);
        
        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];
        
        NSString *nameVal = self.fileFolder.visibleName;
        if(self.fileFolder.detail && self.fileFolder.detail.songTitle) {
            nameVal = self.fileFolder.detail.songTitle;
        }
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:nameVal];
        [self addSubview:nameLabel];
        
        NSString *detailVal = @"";
        if(self.fileFolder.detail && self.fileFolder.detail.artist) {
            detailVal = self.fileFolder.detail.artist;
        }
        if(self.fileFolder.detail && self.fileFolder.detail.album) {
            detailVal = [NSString stringWithFormat:@"%@ - %@", detailVal, self.fileFolder.detail.album];
        }
        
        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:detailVal];
        [self addSubview:detailLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [self readPassiveSeparatorColor];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        [self initializeSwipeMenu];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  ImageCell.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftIndex, 16, 35, 35)];
        [self.imgView setImageWithURL:[NSURL URLWithString:self.fileFolder.detail.thumbSmallUrl]];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

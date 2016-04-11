//
//  SimpleDocCell.m
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SimpleDocCell.h"

@interface SimpleDocCell () {
    CustomLabel *nameLabel;
    CustomLabel *detailLabel;
    UIView *progressSeparator;
}
@end

@implementation SimpleDocCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withFileFolder:_fileFolder isSelectible:_selectible];
    if (self) {
        if(self.isSelectible) {
            self.checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(15, 24, 21, 20) isInitiallyChecked:NO autoActionFlag:NO];
            [self.checkButton addTarget:self action:@selector(triggerFileSelectDeselect) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.checkButton];
        }
        
        int leftIndex = self.isSelectible ? 50 : 15;
        
        CGRect nameFieldRect = CGRectMake(leftIndex + 15, 13, self.frame.size.width - 30, 22);
        CGRect detailFieldRect = CGRectMake(leftIndex + 15, 35, self.frame.size.width - 30, 20);
        
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

- (void) layoutSubviews {
    NSLog(@"At layoutSubviews: %@", NSStringFromCGRect(self.frame));
    int leftIndex = self.isSelectible ? 50 : 15;
    if(self.checkButton) {
        self.checkButton.frame = CGRectMake(15, (self.frame.size.height - 20)/2, 21, 20);
    }
    CGRect nameFieldRect = CGRectMake(leftIndex + 15, self.frame.size.height/2 - 22, self.frame.size.width - 30, 22);
    CGRect detailFieldRect = CGRectMake(leftIndex + 15, self.frame.size.height/2, self.frame.size.width - 30, 20);
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

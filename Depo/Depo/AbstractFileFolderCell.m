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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fileFolder = _fileFolder;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
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

//
//  AbstractFileFolderCell.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppUtil.h"

@interface AbstractFileFolderCell : UITableViewCell

@property (nonatomic, strong) MetaFile *fileFolder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder;
- (UIFont *) readNameFont;
- (UIFont *) readDetailFont;
- (UIColor *) readNameColor;
- (UIColor *) readDetailColor;
- (UIColor *) readPassiveSeparatorColor;

@end

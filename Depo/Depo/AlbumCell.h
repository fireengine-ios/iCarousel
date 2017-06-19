//
//  AlbumCell.h
//  Depo
//
//  Created by Salih GUC on 28/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//


#import "AbstractFileFolderCell.h"

@interface AlbumCell : AbstractFileFolderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder isSelectible:(BOOL)_selectible;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder highlightedText:(NSString *)highlightedText;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withFileFolder:(MetaFile *) _fileFolder;

@end


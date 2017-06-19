//
//  FolderEmptyCell.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderEmptyCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFolderTitle:(NSString *) folderTitle;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFolderTitle:(NSString *) folderTitle withDescMessage:(NSString *) msgKey;

@end

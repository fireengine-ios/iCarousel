//
//  GroupedPhotosCell.h
//  Depo
//
//  Created by Mahir Tarlan on 26/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfoGroup.h"
#import "AppConstants.h"

@interface GroupedPhotosCell : UITableViewCell

@property (nonatomic, strong) FileInfoGroup *group;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group withLevel:(ImageGroupLevel) level;

@end

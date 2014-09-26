//
//  MoreMenuCell.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface MoreMenuCell : UITableViewCell

@property (nonatomic) MoreMenuType menuType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMenuType:(MoreMenuType) _menuType;

@end

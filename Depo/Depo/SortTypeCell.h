//
//  SortTypeCell.h
//  Depo
//
//  Created by Mahir on 30/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface SortTypeCell : UITableViewCell

@property (nonatomic) SortType type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSortType:(SortType) _type;

@end

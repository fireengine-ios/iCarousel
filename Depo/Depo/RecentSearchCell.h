//
//  RecentSearchCell.h
//  Depo
//
//  Created by NCO on 24/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchHistory.h"

@interface RecentSearchCell : UITableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHistory:(SearchHistory *)history;

@end

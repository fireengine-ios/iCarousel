//
//  RecentActivityCell.h
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "CustomLabel.h"

@interface RecentActivityCell : UITableViewCell {
    UIView *timeline;
    UIView *separator;
    CustomLabel *titleLabel;
    CustomLabel *dateLabel;
}

@property (nonatomic, strong) Activity *activity;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withActivity:(Activity *) _activity;

@end

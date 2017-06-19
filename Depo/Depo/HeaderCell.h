//
//  HeaderCell.h
//  Depo
//
//  Created by Mustafa Talha Celik on 25.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderCell : UITableViewCell {
    NSString *headerText;
    BOOL hasHeader;
    double separatorTop;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier headerText:(NSString *)_headerText;

@end

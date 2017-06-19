//
//  MessageCell.h
//  Depo
//
//  Created by RDC on 02.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface MessageCell : UITableViewCell {
    
}

@property (nonatomic, retain) UISwitch *switchButton;

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)titleText;

@end

//
//  CountrySelectionCell.h
//  Depo
//
//  Created by RDC on 16/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface CountrySelectionCell : UITableViewCell

@property (nonatomic, readwrite) CustomLabel *textLabel;
@property (nonatomic, readwrite) CustomLabel *detailTextLabel;

@end

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

@property (nonatomic, strong) CustomLabel *textLabel;
@property (nonatomic, strong) CustomLabel *detailTextLabel;
@property (nonatomic, strong) UIImageView *tickImageV;

- (void) addGreenTickIcon;
- (void) removeGreenTickIcon;

@end

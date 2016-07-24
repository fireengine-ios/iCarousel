//
//  TitleWithSwitchCell.h
//  Depo
//
//  Created by Mahir Tarlan on 21/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@protocol TitleWithSwitchDelegate <NSObject>
- (void) titleWithSwitchValueChanged:(BOOL) isOn forKey:(NSString *) switchKeyRef;
@end

@interface TitleWithSwitchCell : UITableViewCell

@property (nonatomic, weak) id<TitleWithSwitchDelegate> delegate;
@property (nonatomic, strong) UISwitch *onOffswitch;
@property (nonatomic, strong) NSString *switchKey;
@property (nonatomic, strong) CustomLabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic) int rowIndex;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withIcon:(NSString *) iconVal withTitle:(NSString *) titleVal withSwitchKey:(NSString *) switchKeyVal withIndex:(int) indexVal;

@end

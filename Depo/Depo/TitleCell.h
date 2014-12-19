//
//  TitleCell.h
//  Depo
//
//  Created by Salih on 22.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface TitleCell : UITableViewCell {
    NSString *titleText;
    double titleLeft;
    double titleTop;
    UIColor *titleColor;
    double titleFontSize;
    BOOL hasSubTitle;
    NSString *subTitleText;
    BOOL hasIcon;
    NSString *iconName;
    BOOL hasSeparator;
    BOOL isLink;
    NSString *linkText;
    BOOL hasCheckStatus;
    BOOL checkStatus;
    UISwitch *switchButton;
    BOOL switchButtonStatus;
    double cellHeight;
    UIImageView *tickIcon;
}

@property (nonatomic, retain) UISwitch *switchButton;

- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText titleColor:(UIColor *)_titleColor subTitleText:(NSString *)_subTitleText iconName:(NSString *)_iconName hasSeparator:(BOOL)_hasSeparator isLink:(BOOL)_isLink linkText:(NSString *)_linkText cellHeight:(double)_cellHeight;
- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier iconName:(NSString *)_iconName titleText:(NSString *)_titleText checkStatus:(BOOL)_checkStatus;
- (id)initWithCellStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleText:(NSString *)_titleText subTitletext:(NSString *)_subTitleText SwitchButtonStatus:(BOOL)_switchButtonStatus;
- (void)showTick;
- (void)hideTick;

@end

//
//  MenuCell.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaMenu.h"
#import "AbstractMenuCell.h"
#import "AppConstants.h"
#import "CustomButton.h"

@protocol SubMenuCollapseDelegate <NSObject>
- (void) didTriggerCollapse:(MenuType) sectionType;
@end

@interface MenuCell : AbstractMenuCell {
    UIImageView *iconView;
    CustomButton *collapseButton;
    CustomButton *expandButton;
    UILabel *titleLabel;
}

@property (nonatomic, strong) UIImage *unselectedIcon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) id<SubMenuCollapseDelegate> collapseDelegate;
@property (nonatomic) BOOL collapsed;
@property (nonatomic) BOOL collapsible;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMetaData:(MetaMenu *) _metaData isCollapsible:(BOOL) isCollapsible isCollapsed:(BOOL) isCollapsed;
- (void) collapseTriggered;

@end

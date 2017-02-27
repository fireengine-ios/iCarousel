//
//  MenuCell.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "MenuCell.h"
#import "Util.h"
#import "CustomButton.h"

@implementation MenuCell

@synthesize unselectedIcon;
@synthesize selectedIcon;
@synthesize collapseDelegate;
@synthesize collapsed;
@synthesize collapsible;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMetaData:(MetaMenu *) _metaData isCollapsible:(BOOL) isCollapsible isCollapsed:(BOOL) isCollapsed {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        
        self.metaData = _metaData;
        self.collapsible = isCollapsible;
        self.collapsed = isCollapsed;
        
        self.unselectedIcon = [UIImage imageNamed:self.metaData.iconName];
        self.selectedIcon =[UIImage imageNamed:self.metaData.selectedIconName];

        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (60 - unselectedIcon.size.height)/2, unselectedIcon.size.width, unselectedIcon.size.height)];
        iconView.image = unselectedIcon;
        [self addSubview:iconView];

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, (60 - 20)/2, self.frame.size.width - 55, 20)];
        titleLabel.text = self.metaData.title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
//        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textColor = [Util UIColorForHexColor:@"DEDEDE"];
        [self addSubview:titleLabel];
        
        if(collapsible) {
            collapseButton = [[CustomButton alloc] initWithFrame:CGRectMake(238, 10, 40, 40) withImageName:@"acik.png"];
            [collapseButton addTarget:self action:@selector(collapseTriggered) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:collapseButton];

            expandButton = [[CustomButton alloc] initWithFrame:CGRectMake(238, 10, 40, 40) withImageName:@"menu_icon_plus.png"];
            [expandButton addTarget:self action:@selector(collapseTriggered) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:expandButton];

            if(collapsed) {
                collapseButton.hidden = YES;
                expandButton.hidden = NO;
            } else {
                collapseButton.hidden = NO;
                expandButton.hidden = YES;
            }
        }

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        iconView.image = selectedIcon;
        titleLabel.textColor = [Util UIColorForHexColor:@"FFEE00"];
    } else {
        iconView.image = unselectedIcon;
        titleLabel.textColor = [Util UIColorForHexColor:@"DEDEDE"];
    }
}

- (void) collapseTriggered {
    [collapseDelegate didTriggerCollapse:self.metaData.menuType];
    collapsed = !collapsed;
    if(collapsed) {
        collapseButton.hidden = YES;
        expandButton.hidden = NO;
    } else {
        collapseButton.hidden = NO;
        expandButton.hidden = YES;
    }
}


@end
